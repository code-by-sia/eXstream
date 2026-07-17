import "std/config.xi"
import "std/convert.xi"
import "std/web.xi"

// Root module for the auth service. Gathers every file under auth/ and
// common/ by glob; persistence uses std/data's CrudRepository over the
// SqliteQueryProvider (common/data), backed by the vendored sqlite binding
// (common/sqlite) — no external dependency. Build with `xc auth-service.xi`.
module App {
    id = "auth-service"
    name = "eXstream Auth Service"
    version = "0.1.0"
    includes = ["auth/**", "common/**"]
    excludes = ["auth/test/**"]

    bind AppConfig -> readConfig("common/config.yaml")
    // One SqliteQueryProvider instance backs both views so query chains and
    // writes run on the connection DatabaseInit opens.
    bind QueryProvider  -> SqliteQueryProvider as singleton
    bind DatabaseBinder -> SqliteQueryProvider as singleton

    async entry (dbInit: DatabaseInit, seeder: DataSeeder, config: AppConfig) main(args: String[]) -> Integer {
        dbInit.ensure()
        let port = config.authPort()
        if args.len >= 2 {
            let parsed = convert.parseInteger(args.data[1])
            if isOk(parsed) { port = parsed.value }
        }
        seeder.seedDefaultUsers()
        web.serve(port)
    }
}
