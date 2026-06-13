import "business/playlists.xi"
import "std/config.xi"
import "std/convert.xi"
import "std/web.xi"

module App {
    id = "playlist-service"
    name = "eXstream Playlist Service"
    version = "0.1.0"
    includes = ["./playlist-service.xi"]
    excludes = ["./test/**"]

    bind AppConfig -> readConfig("common/config.yaml")

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
