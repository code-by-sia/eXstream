// Vendored xi-sqlite raw binding (ffi + api + system only — no query.xi, whose
// SqliteQueryProvider predates Xi 0.1.0 "Berlin"'s 3-method QueryProvider
// contract). Import THIS file; it loads the parts in the required order.
import "./ffi.xi"
import "./api.xi"
import "./system.xi"
