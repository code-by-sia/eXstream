import "api/auth-api.xi"
import "business/users.xi"
import "business/user-seeder.xi"
import "std/convert.xi"
import "std/web.xi"

module App {
    id = "auth-service"
    name = "eXstream Auth Service"
    version = "0.1.0"
    includes = ["./auth-service.xi", "../common/**"]
    excludes = ["./test/**"]

    async entry main(args: String[]) -> Integer {
        let port = 4001
        if args.len >= 2 {
            let parsed = convert.parseInteger(args.data[1])
            if isOk(parsed) { port = parsed.value }
        }
        seedDefaultUsers(App.resolve(UserRepository))
        web.serve(port)
    }
}
