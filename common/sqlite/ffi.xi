// xi-sqlite: the raw C binding — extern declarations against the system
// sqlite3 library, the sqlite3 status codes used here, and low-level string
// helpers. Internal; apps should use the sqlite.SQLite interface instead.
//
// This file is un-namespaced (Xi allows one file per namespace), so its names
// carry a SQLITE_/sqlite prefix to stay out of the way.
import "std/ffi.xi"
import "std/json.xi"

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

    // Parameter binding (1-based slots). `destructor` is declared Integer so we
    // can pass SQLITE_TRANSIENT (-1) — the register-sized value lands as the
    // ((void*)-1) sentinel, telling sqlite to copy the bound text immediately.
    producer sqlite3_bind_text(stmt: Ptr, slot: Integer, val: cstring, nByte: Integer, destructor: Integer) -> Integer
    producer sqlite3_bind_int64(stmt: Ptr, slot: Integer, val: Integer) -> Integer
    producer sqlite3_bind_double(stmt: Ptr, slot: Integer, val: Number) -> Integer
    producer sqlite3_bind_null(stmt: Ptr, slot: Integer) -> Integer
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

// Tells sqlite3_bind_text to make its own copy of the string.
mapper SQLITE_TRANSIENT() -> Integer => 0 - 1

// Copy a C string into Xi-owned memory. sqlite reuses/frees the buffers behind
// errmsg/column_name/column_text, and fromCString only wraps the pointer, so
// anything kept past the next sqlite call must be copied (`+ ""` allocates).
mapper sqliteOwnText(p: cstring) -> String => fromCString(p) + ""

producer sqliteErrorOn(db: Ptr) -> String {
    let message = sqliteOwnText(sqlite3_errmsg(db))
    if message == "" { return "sqlite error" }
    return message
}

// Bind a Json array of values onto a prepared statement's `?` placeholders, in
// order. null/bool/number/string map to the matching sqlite bind; text is
// copied (SQLITE_TRANSIENT), so callers may bind, then step, then finalize
// without keeping the source strings alive.
producer sqliteBindParams(stmt: Ptr, params: Json) {
    for i in 0 until json.length(params) {
        let v = json.at(params, i)
        let slot = i + 1
        let kind = json.kind(v)
        if kind == 0 { let r = sqlite3_bind_null(stmt, slot) }
        else { if kind == 1 { let r = sqlite3_bind_int64(stmt, slot, boolToInt(json.asBool(v))) }
        else { if kind == 2 { let r = sqlite3_bind_double(stmt, slot, json.asNumber(v)) }
        else { let r = sqlite3_bind_text(stmt, slot, toCString(json.asString(v)), -1, SQLITE_TRANSIENT()) } } }
    }
}

mapper boolToInt(b: Bool) -> Integer { if b { return 1 } return 0 }
