// xi-sqlite: the public API — the sqlite namespace.
//
// Holds the data types, the interfaces (SQLite, RowReader, ColumnDecoder), and
// the default Value-handling implementations. Everything is exposed through an
// interface so apps can rebind any piece in their `module App`/`module Test`.
// Types, interfaces, and the Value-matching classes share this file because a
// Xi namespace cannot span files; SystemSQLite lives separately in system.xi.
namespace sqlite

import "std/ffi.xi"
import "std/json.xi"

// An open connection, as returned by SQLite.open().
type Database = { handle: Ptr }

// A typed SQL value: one variant per sqlite storage class (blobs arrive as Text).
type Value = | IntValue { i: Integer } | RealValue { n: Number } | TextValue { s: String } | NullValue

// One result row: column name -> typed value.
type Row = { columns: Map<String, Value> }

// All rows of a query result; iterate with `for row in rows.items`.
type Rows = { items: List<Row> }

// Depend on this interface (`deps { sql: sqlite.SQLite }`, or in an entry/test
// signature) and the compiler injects the bundled implementation,
// SystemSQLite. Every fallible call returns a result (`T!`); nothing aborts.
interface SQLite {
    // Open (and create if missing) a database file; ":memory:" for in-memory.
    producer open(path: String) -> Database!
    producer close(db: Database) -> Bool!
    // Run one or more statements that return no rows (DDL, insert/update/delete).
    producer exec(db: Database, sql: String) -> Bool!
    // Like exec, with `?` placeholders bound from a Json array (injection-safe).
    producer execBound(db: Database, sql: String, params: Json) -> Bool!
    // Run a select and collect every row.
    producer query(db: Database, sql: String) -> Rows!
    // Like query, with `?` placeholders bound from a Json array (injection-safe).
    producer queryBound(db: Database, sql: String, params: Json) -> Rows!
    // Run a select and render the rows as a JSON array of objects, in column order.
    producer queryJson(db: Database, sql: String) -> String!
    // Rowid of the most recent successful insert on this connection.
    producer lastInsertId(db: Database) -> Integer
    // Rows changed by the most recent insert/update/delete.
    producer changes(db: Database) -> Integer
}

// Reads typed values out of a Row. Missing columns and type mismatches yield
// the fallback you pass in. Implemented by TypedRowReader.
interface RowReader {
    predicate hasColumn(row: Row, name: String)
    predicate isNull(row: Row, name: String)
    projector intAt(row: Row, name: String, fallback: Integer) -> Integer
    projector numberAt(row: Row, name: String, fallback: Number) -> Number
    projector textAt(row: Row, name: String, fallback: String) -> String
}

// Turns a statement column into a Value and a Value into Json; SystemSQLite
// depends on this, so rebinding it changes how every query decodes columns.
// Implemented by TypedColumnDecoder.
interface ColumnDecoder {
    producer decode(stmt: Ptr, col: Integer) -> Value
    mapper toJson(v: Value) -> Json
}

// ── Default implementations ────────────────────────────────────────

class TypedRowReader implements RowReader {
    deps {}

    predicate hasColumn(row: Row, name: String) { return row.columns.has(name) }

    predicate isNull(row: Row, name: String) {
        if row.columns.has(name) {} else { return true }
        match row.columns.get(name) {
            NullValue -> true
            else      -> false
        }
    }

    projector intAt(row: Row, name: String, fallback: Integer) -> Integer {
        if row.columns.has(name) {} else { return fallback }
        match row.columns.get(name) {
            IntValue x -> x.i
            else       -> fallback
        }
    }

    projector numberAt(row: Row, name: String, fallback: Number) -> Number {
        if row.columns.has(name) {} else { return fallback }
        match row.columns.get(name) {
            RealValue x -> x.n
            IntValue x  -> x.i
            else        -> fallback
        }
    }

    projector textAt(row: Row, name: String, fallback: String) -> String {
        if row.columns.has(name) {} else { return fallback }
        match row.columns.get(name) {
            TextValue x -> x.s
            else        -> fallback
        }
    }
}

class TypedColumnDecoder implements ColumnDecoder {
    deps {}

    producer decode(stmt: Ptr, col: Integer) -> Value {
        let kind = sqlite3_column_type(stmt, col)
        if kind == SQLITE_T_INT()   { return IntValue { i: sqlite3_column_int64(stmt, col) } }
        if kind == SQLITE_T_FLOAT() { return RealValue { n: sqlite3_column_double(stmt, col) } }
        if kind == SQLITE_T_NULL()  { return NullValue }
        return TextValue { s: sqliteOwnText(sqlite3_column_text(stmt, col)) }
    }

    mapper toJson(v: Value) -> Json {
        match v {
            IntValue x  -> json.int(x.i)
            RealValue x -> json.num(x.n)
            TextValue x -> json.str(x.s)
            else        -> json.nul()
        }
    }
}
