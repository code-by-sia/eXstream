import "api/file-api.xi"
import "business/sqlite-file-repository.xi"
import "std/convert.xi"
import "std/web.xi"

module App {
    id = "file-service"
    name = "eXstream File Service"
    version = "0.1.0"
    includes = ["./file-service.xi", "../common/**"]
    excludes = ["./test/**"]

    async entry main(args: String[]) -> Integer {
        let port = 6001
        if args.len >= 2 {
            let parsed = convert.parseInteger(args.data[1])
            if isOk(parsed) { port = parsed.value }
        }
        web.serve(port)
    }
}
