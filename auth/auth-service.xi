import "business/auth.xi"
import "std/config.xi"
import "std/convert.xi"
import "std/web.xi"

module App {
    id = "auth-service"
    name = "eXstream Auth Service"
    version = "0.1.0"
    includes = ["./auth-service.xi"]
    excludes = ["./test/**"]

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
