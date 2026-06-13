// xi-sqlite: the raw C binding — extern declarations against the system
// sqlite3 library, the sqlite3 status codes used here, and low-level string
// helpers. Internal; apps should use the sqlite.SQLite interface instead.
//
// This file is un-namespaced (Xi allows one file per namespace), so its names
// carry a SQLITE_/sqlite prefix to stay out of the way.
import "std/ffi.xi"

extern "C" {
    link "sqlite3"

    producer sqlite3_open(path: cstring, ppDb: &mut Ptr) -> Integer
    producer sqlite3_close(db: Ptr) -> Integer
    producer sqlite3_errmsg(db: Ptr) -> cstring
    producer sqlite3_exec(db: Ptr, sql: cstring, callback: Ptr, arg: Ptr, errmsg: Ptr) -> Integer
    producer sqlite3_prepare_v2(db: Ptr, sql: cstring, nByte: Integer, ppStmt: &mut Ptr, pzTail: Ptr) -> Integer
    producer sqlite3_step(stmt: Ptr) -> Integer
    producer sqlite3_finalize(stmt: Ptr) -> Integer
    producer sqlite3_column_count(stmt: Ptr) -> Integer
    producer sqlite3_column_type(stmt: Ptr, col: Integer) -> Integer
    producer sqlite3_column_name(stmt: Ptr, col: Integer) -> cstring
    producer sqlite3_column_text(stmt: Ptr, col: Integer) -> cstring
    producer sqlite3_column_int64(stmt: Ptr, col: Integer) -> Integer
    producer sqlite3_column_double(stmt: Ptr, col: Integer) -> Number
    producer sqlite3_changes(db: Ptr) -> Integer
    producer sqlite3_last_insert_rowid(db: Ptr) -> Integer
}

// sqlite3 result / column-type codes used here
mapper SQLITE_OK() -> Integer      => 0
mapper SQLITE_ROW() -> Integer     => 100
mapper SQLITE_DONE() -> Integer    => 101
mapper SQLITE_T_INT() -> Integer   => 1
mapper SQLITE_T_FLOAT() -> Integer => 2
mapper SQLITE_T_TEXT() -> Integer  => 3
mapper SQLITE_T_BLOB() -> Integer  => 4
mapper SQLITE_T_NULL() -> Integer  => 5

// Copy a C string into Xi-owned memory. sqlite reuses/frees the buffers behind
// errmsg/column_name/column_text, and fromCString only wraps the pointer, so
// anything kept past the next sqlite call must be copied (`+ ""` allocates).
mapper sqliteOwnText(p: cstring) -> String => fromCString(p) + ""

producer sqliteErrorOn(db: Ptr) -> String {
    let message = sqliteOwnText(sqlite3_errmsg(db))
    if message == "" { return "sqlite error" }
    return message
}
