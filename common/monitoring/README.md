# Monitoring & tracing

## What's wired in

Every service (`auth`, `playlist`, `file`) enables Xi 0.1's `std/monitoring`:

- `GET /monitor/health` — `{"status":"UP","checks":{...}}` (503 when down)
- `GET /monitor/metrics` — uptime, CPU, memory, request-count, as JSON
- `GET /monitor/info` — module id/name/version
- `GET /metrics` — the same data as Prometheus text exposition format
  (`common/monitoring/prometheus-exporter.xi`), scraped by the `prometheus`
  compose service. Open http://localhost:9090 to query it.

## Why there's no live Zipkin instrumentation

A `zipkin` container is included in `docker-compose.yml`, ready at
`http://zipkin:9411`, but the Xi services don't report spans to it.

Xi's `std/http` client (`http.get`/`http.post`) reliably **crashes the process
with heap corruption** (`munmap_chunk(): invalid pointer`) when called from
*inside* a request handler that's running under `web.serve()` — reproduced on
both macOS and Linux, in a minimal isolated repro (no JSON building, no other
service code — a bare `http.get()` inside one `action handle`). The same call
works perfectly in a plain CLI that never calls `web.serve()` (e.g.
`loadtest.xi`, at the repo root, is unaffected).

Since every request handler in these services runs inside `web.serve()`,
there's currently no safe way for a handler to make an outbound HTTP call to
Zipkin's collector without risking a crash of the whole service. Instrumenting
handlers for distributed tracing will become straightforward once this is
fixed upstream (or once Xi ships an async/non-blocking HTTP client, or a
socket API safe to use from a handler) — at that point, reporting a span is
just building a small JSON object and POSTing it to
`http://zipkin:9411/api/v2/spans`.
