import "std/json.xi"
import "std/monitoring.xi"
import "std/text.xi"
import "std/web.xi"

// Renders std/monitoring's report as Prometheus text exposition format, so a
// real Prometheus server can scrape this service directly (its own
// `/monitor/metrics` endpoint from std/monitoring/web.xi is JSON, which
// Prometheus can't parse). Every gauge is labeled `service="<module id>"` so
// one Prometheus can distinguish auth/playlist/file.
//
//     GET /metrics   text/plain; version=0.0.4
class PrometheusController implements WebRequestHandler {
    deps { mon: MonitoringRegistry as singleton }

    mapper getBaseUrl() -> String => "/"

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/metrics" and req.method == "GET" {
        if not mon.isEnabled() { res.sendStatus(404, "Not Found") return }
        res.sendText(200, render(mon.report(), mon.healthy()))
    }

    // Deliberately NO unconditional catch-all here: with multiple
    // WebRequestHandler classes bound, the first one whose method list ends in
    // an unconditional match swallows every path no earlier class claimed —
    // including ones meant for classes registered after it. Leaving `/metrics`
    // as the only guard lets anything else fall through to the app's own
    // controller, which owns the final 404.

    mapper render(report: Json, healthy: Bool) -> String {
        let service = monitor.info(0)
        let labels = "{service=\"" + service + "\"}"
        let out = gaugeLine("up", "1 if the monitoring registry reports healthy", labels, boolValue(healthy))

        let n = json.length(report)
        let i = 0
        while i < n {
            let key = json.keyAt(report, i)
            let item = json.get(report, key)
            if json.isNumber(item) { out = out + gaugeLine(key, "Xi monitoring gauge.", labels, json.asNumber(item)) }
            if json.isObject(item) { out = out + renderNested(key, labels, item) }
            i = i + 1
        }
        return out
    }

    mapper renderNested(prefix: String, labels: String, obj: Json) -> String {
        let out = ""
        let n = json.length(obj)
        let i = 0
        while i < n {
            let key = json.keyAt(obj, i)
            let item = json.get(obj, key)
            if json.isNumber(item) { out = out + gaugeLine(prefix + "_" + key, "Xi monitoring gauge.", labels, json.asNumber(item)) }
            i = i + 1
        }
        return out
    }

    mapper gaugeLine(name: String, help: String, labels: String, gaugeValue: Number) -> String {
        let metric = "xi_" + snakeCase(name)
        return $"# HELP ${metric} ${help}\n# TYPE ${metric} gauge\n${metric}${labels} ${gaugeValue}\n"
    }

    mapper boolValue(b: Bool) -> Integer {
        if b { return 1 }
        return 0
    }

    // camelCase -> snake_case, so metric names satisfy Prometheus's naming
    // convention (e.g. "peakRssBytes" -> "peak_rss_bytes").
    mapper snakeCase(s: String) -> String {
        let out = ""
        let n = text.length(s)
        let i = 0
        while i < n {
            let code = text.charAt(s, i)
            if code >= 65 and code <= 90 {
                out = out + "_" + text.fromCharCode(code + 32)
            } else {
                out = out + text.fromCharCode(code)
            }
            i = i + 1
        }
        return out
    }
}
