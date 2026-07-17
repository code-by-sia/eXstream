// A very small load-test CLI: fires N sequential GET requests at a URL and
// reports latency (min/avg/p50/p95/max), throughput, and this process's own
// memory footprint (RSS, read from /proc/self/status). Reports "n/a" if that
// file can't be read as a normal file — this Xi runtime's file reader sizes
// its buffer from stat(), which /proc reports as 0 bytes, so it comes back
// empty even on Linux; kept as a graceful, honestly-labeled fallback rather
// than a raw getrusage() FFI binding, to keep this module small.
//
// Usage: ./build/loadtest <baseUrl> <path> [count]
//   ./build/loadtest http://localhost:4001 /health 200
//
// std/http's client has no custom-header support, so this targets public,
// unauthenticated endpoints (each service's /health) by design — a
// deliberately small tool, not a full benchmarking harness.
import "std/convert.xi"
import "std/fs.xi"
import "std/http.xi"
import "std/log.xi"
import "std/math.xi"
import "std/text.xi"
import "std/time.xi"

type RunResult = { latenciesMs: List<Number>, okCount: Integer, failCount: Integer, totalMs: Number }

interface LoadRunner {
    producer run(baseUrl: String, path: String, count: Integer) -> RunResult
}

class HttpLoadRunner implements LoadRunner {
    deps {}

    producer run(baseUrl: String, path: String, count: Integer) -> RunResult {
        let latencies = empty List<Number>
        let ok = 0
        let fail = 0
        let url = baseUrl + path

        let started = time.nowNanos()
        let i = 0
        while i < count {
            let reqStart = time.nowNanos()
            let resp = http.get(url)
            let elapsedNanos = time.nowNanos() - reqStart
            let reqMs = elapsedNanos / 1000000.0
            latencies.push(reqMs)
            if isOk(resp) and resp.value.status >= 200 and resp.value.status < 300 { ok = ok + 1 } else { fail = fail + 1 }
            i = i + 1
        }
        let totalNanos = time.nowNanos() - started
        let totalMs = totalNanos / 1000000.0

        return RunResult { latenciesMs: latencies, okCount: ok, failCount: fail, totalMs: totalMs }
    }
}

// Reads this process's resident memory in KB from /proc/self/status.
// Returns none where /proc isn't available (e.g. macOS).
mapper residentMemoryKb() -> Integer? {
    if not fs.exists("/proc/self/status") { return none }
    let read = fs.readFile("/proc/self/status")
    if isErr(read) { return none }
    for line in text.split(read.value, "\n") {
        if text.startsWith(line, "VmRSS:") {
            // Line shape: "VmRSS:\t    1234 kB" — the numeric token sits
            // between the label and the unit.
            for token in text.split(line, " ") {
                let parsed = convert.parseInteger(token)
                if isOk(parsed) { return parsed.value }
            }
        }
    }
    return none
}

mapper sorted(values: List<Number>) -> List<Number> {
    let out = empty List<Number>
    for v in values { out.push(v) }
    let n = out.len()
    let i = 1
    while i < n {
        let key = out.get(i)
        let j = i - 1
        while j >= 0 and out.get(j) > key {
            out.set(j + 1, out.get(j))
            j = j - 1
        }
        out.set(j + 1, key)
        i = i + 1
    }
    return out
}

mapper percentile(sortedValues: List<Number>, p: Number) -> Number {
    if sortedValues.isEmpty() { return 0.0 }
    let lastIndex = sortedValues.len() - 1
    let idx = p * lastIndex
    return sortedValues.get(idx)
}

mapper sum(values: List<Number>) -> Number {
    let total = 0.0
    for v in values { total = total + v }
    return total
}

mapper round2(n: Number) -> Number => math.round(n * 100.0) / 100.0

interface Reporter {
    consumer report(baseUrl: String, path: String, count: Integer)
}

class LoadTestReport implements Reporter {
    deps { logger: Logger, runner: LoadRunner }

    consumer report(baseUrl: String, path: String, count: Integer) {
        logger.info($"Load test: ${count} sequential GET ${baseUrl}${path}")
        let result = runner.run(baseUrl, path, count)
        let latencies = sorted(result.latenciesMs)

        let avgMs = round2(sum(latencies) / latencies.len())
        let minMs = round2(latencies.get(0))
        let maxMs = round2(latencies.get(latencies.len() - 1))
        let p50Ms = round2(percentile(latencies, 0.50))
        let p95Ms = round2(percentile(latencies, 0.95))
        let totalSeconds = result.totalMs / 1000.0
        let throughput = round2(count / totalSeconds)

        logger.info("--- latency (ms) ---")
        logger.info($"min=${minMs}  p50=${p50Ms}  avg=${avgMs}  p95=${p95Ms}  max=${maxMs}")
        logger.info("--- throughput ---")
        logger.info($"${result.okCount} ok, ${result.failCount} failed, ${throughput} req/s over ${round2(result.totalMs)} ms")
        logger.info("--- memory (this load-test process) ---")
        if let rssKb = residentMemoryKb() {
            logger.info($"RSS: ${rssKb} KB")
        } else {
            logger.info("RSS: n/a (no /proc/self/status on this platform)")
        }
    }
}

async entry (report: Reporter) main(args: String[]) -> Integer {
    if args.len < 3 {
        system.stdout.writeln("usage: loadtest <baseUrl> <path> [count]")
        return 1
    }
    let baseUrl = args.data[1]
    let path = args.data[2]
    let count = 50
    if args.len >= 4 {
        let parsed = convert.parseInteger(args.data[3])
        if isOk(parsed) { count = parsed.value }
    }
    report.report(baseUrl, path, count)
    return 0
}

module App {
    id = "loadtest"
    name = "eXstream Load Test"
    includes = ["./loadtest.xi"]
    excludes = [".claude/**"]
}
