import "std/config.xi"
import "std/convert.xi"
import "std/web.xi"

// Root module for the playlist service. Gathers its files by glob; persistence
// uses the generic SqliteQueryProvider (common/data) over the vendored sqlite
// binding (common/sqlite) — no external dependency.
module App {
    id = "playlist-service"
    name = "eXstream Playlist Service"
    version = "0.1.0"
    includes = ["playlist/**", "common/**"]
    excludes = ["playlist/test/**"]

    bind AppConfig -> readConfig("common/config.yaml")
    bind QueryProvider  -> SqliteQueryProvider as singleton
    bind DatabaseBinder -> SqliteQueryProvider as singleton

    async entry (dataSeeder: DataSeeder, config: AppConfig) main(args: String[]) -> Integer {
        let port = config.playlistPort()
        if args.len >= 2 {
            let parsed = convert.parseInteger(args.data[1])
            if isOk(parsed) { port = parsed.value }
        }
        dataSeeder.seedPlaylists()
        web.serve(port)
    }
}
