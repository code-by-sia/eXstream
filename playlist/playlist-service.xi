import "api/playlist-api.xi"
import "business/playlist-seeder.xi"
import "std/convert.xi"
import "std/web.xi"

module App {
    id = "playlist-service"
    name = "eXstream Playlist Service"
    version = "0.1.0"
    includes = ["./playlist-service.xi", "../common/**"]
    excludes = ["./test/**"]

    async entry main(args: String[]) -> Integer {
        let port = 5001
        if args.len >= 2 {
            let parsed = convert.parseInteger(args.data[1])
            if isOk(parsed) { port = parsed.value }
        }
        seedStarterPlaylists(App.resolve(PlaylistRepository))
        web.serve(port)
    }
}
