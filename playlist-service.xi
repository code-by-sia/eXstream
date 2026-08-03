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
// its GET /metrics route win over playlist-api.xi's catch-all 404.
import "common/monitoring/prometheus-exporter.xi"

// Root module for the playlist service. Gathers its files by glob; persistence
// uses the generic SqliteQueryProvider (common/data) over the vendored sqlite
// binding (common/sqlite) — no external dependency.
module App {
    id = "playlist-service"
    name = "eXstream Playlist Service"
    version = "0.1.0"
    includes = ["playlist/**", "common/**"]
    excludes = ["playlist/test/**"]

    bind AppConfig -> readConfig("common/config.yaml")
    bind QueryProvider  -> SqliteQueryProvider as singleton
    bind DatabaseBinder -> SqliteQueryProvider as singleton
    // std/monitoring: GET /monitor/health, /monitor/metrics, /monitor/info
    // (JSON); common/monitoring/prometheus-exporter.xi adds GET /metrics
    // (Prometheus text format) over the same registry.
    bind MonitoringRegistry -> MonitorRegistry as singleton

    async entry (dataSeeder: DataSeeder, config: AppConfig, mon: MonitoringRegistry as singleton) main(args: String[]) -> Integer {
        mon.enable()
        let port = config.playlistPort()
        if args.len >= 2 {
            let parsed = convert.parseInteger(args.data[1])
            if isOk(parsed) { port = parsed.value }
        }
        dataSeeder.seedPlaylists()
        web.serve(port)
    }
}
