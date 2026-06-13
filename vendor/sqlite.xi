// xi-sqlite — SQLite bindings for Xi.
//
// Binds the system `sqlite3` library directly through `extern "C"`; no glue C
// required. Import this file and depend on the `sqlite.SQLite` interface — the
// compiler injects the bundled implementation (`SystemSQLite`) automatically:
//
//   import "path/to/sqlite.xi"
//
//   class Repo {
//       deps { sql: sqlite.SQLite }
//       producer titles() -> String! {
//           let db = sql.open(":memory:")?
//           ...
//       }
//   }
//
// Layout (import THIS file, in this order — the parts don't import each other
// because Xi resolves imports by literal path and would load them twice):
//
//   sqlite/ffi.xi     raw extern "C" binding to libsqlite3 (internal, global)
//   sqlite/api.xi     namespace sqlite: types, the SQLite interface, row accessors
//   sqlite/system.xi  SystemSQLite, the stock implementation
//
// BLOB columns are surfaced as text (sqlite's cast of the raw bytes); select
// `hex(col)` in SQL when you need a stable binary encoding.

import "./sqlite/ffi.xi"
import "./sqlite/api.xi"
import "./sqlite/system.xi"
