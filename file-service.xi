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
// its GET /metrics route win over file-api.xi's catch-all 404.
import "common/monitoring/prometheus-exporter.xi"

// Root module for the file service. Gathers its files by glob — no barrel. The
// file service is disk-backed, so it needs common config + security + the
// monitoring exporter (no sqlite). Build with `xc file-service.xi`.
module App {
    id = "file-service"
    name = "eXstream File Service"
    version = "0.1.0"
    includes = ["file/**", "common/config/**", "common/security/**", "common/monitoring/**"]
    excludes = ["file/test/**"]

    bind AppConfig -> readConfig("common/config.yaml")
    // std/monitoring: GET /monitor/health, /monitor/metrics, /monitor/info
    // (JSON); common/monitoring/prometheus-exporter.xi adds GET /metrics
    // (Prometheus text format) over the same registry.
    bind MonitoringRegistry -> MonitorRegistry as singleton

    async entry (config: AppConfig, mon: MonitoringRegistry as singleton) main(args: String[]) -> Integer {
        mon.enable()
        let port = config.filePort()
        if args.len >= 2 {
            let parsed = convert.parseInteger(args.data[1])
            if isOk(parsed) { port = parsed.value }
        }
        web.serve(port)
    }
}
