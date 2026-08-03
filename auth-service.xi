import "std/config.xi"
import "std/convert.xi"
import "std/monitoring.xi"
import "std/monitoring/cpu.xi"
import "std/monitoring/memory.xi"
import "std/monitoring/web.xi"
import "std/web.xi"
// Explicitly imported (not just glob-discovered): with multiple
// WebRequestHandler classes bound, registration order follows explicit
// imports first, then includes-glob discovery — importing this here makes
// its GET /metrics route win over auth-api.xi's catch-all 404.
import "common/monitoring/prometheus-exporter.xi"

// Root module for the auth service. Gathers every file under auth/ and
// common/ by glob; persistence goes through the SqliteQueryProvider
// (common/data), backed by the vendored sqlite binding (common/sqlite) — no
// external dependency. Build with `xc auth-service.xi`.
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
    // std/monitoring: GET /monitor/health, /monitor/metrics, /monitor/info
    // (JSON); common/monitoring/prometheus-exporter.xi adds GET /metrics
    // (Prometheus text format) over the same registry.
    bind MonitoringRegistry -> MonitorRegistry as singleton

    async entry (dbInit: DatabaseInit, seeder: DataSeeder, config: AppConfig, mon: MonitoringRegistry as singleton) main(args: String[]) -> Integer {
        mon.enable()
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
