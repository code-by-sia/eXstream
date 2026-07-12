import "std/config.xi"
import "std/convert.xi"
import "std/web.xi"

// Root module for the auth service. It gathers every file under auth/ and
// common/ by glob, and pulls xi-sqlite via `dependencies` (`xi install`).
// Build with `xc auth-service.xi`.
module App {
    id = "auth-service"
    name = "eXstream Auth Service"
    version = "0.1.0"
    includes = ["auth/**", "common/**"]
    excludes = ["auth/test/**"]
    dependencies = ["https://github.com/code-by-sia/xi-sqlite/archive/refs/tags/v0.2.0.tar.gz"]

    bind AppConfig -> readConfig("common/config.yaml")
    // One SqliteQueryProvider instance backs both views so query chains run on
    // the connection attached via DatabaseBinder.
    bind QueryProvider  -> SqliteQueryProvider as singleton
    bind DatabaseBinder -> SqliteQueryProvider as singleton

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
