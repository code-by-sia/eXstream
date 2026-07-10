import "std/config.xi"
import "std/convert.xi"
import "std/web.xi"

// Root module for the file service. Gathers its files by glob — no barrel. The
// file service is disk-backed, so it needs common config + security only (no
// sqlite). Build with `xc file-service.xi`.
module App {
    id = "file-service"
    name = "eXstream File Service"
    version = "0.1.0"
    includes = ["file/**", "common/config/**", "common/security/**"]
    excludes = ["file/test/**"]

    bind AppConfig -> readConfig("common/config.yaml")

    async entry (config: AppConfig) main(args: String[]) -> Integer {
        let port = config.filePort()
        if args.len >= 2 {
            let parsed = convert.parseInteger(args.data[1])
            if isOk(parsed) { port = parsed.value }
        }
        web.serve(port)
    }
}
