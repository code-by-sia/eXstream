import "std/config.xi"
import "std/convert.xi"
import "std/web.xi"

// Root module for the auth service. It gathers every file under auth/, common/,
// and the vendored sqlite binding by glob — no hand-ordered import barrel.
// Build with `xc auth-service.xi`.
module App {
    id = "auth-service"
    name = "eXstream Auth Service"
    version = "0.1.0"
    includes = ["auth/**", "common/**", "vendor/sqlite.xi"]
    excludes = ["auth/test/**"]

    bind AppConfig -> readConfig("common/config.yaml")

    async entry (seeder: DataSeeder, config: AppConfig) main(args: String[]) -> Integer {
        let port = config.authPort()
        if args.len >= 2 {
            let parsed = convert.parseInteger(args.data[1])
            if isOk(parsed) { port = parsed.value }
        }
        seeder.seedDefaultUsers()
        web.serve(port)
    }
}
