// xi-sqlite: the stock SQLite implementation over the system sqlite3 library.
// Resolved for the sqlite.SQLite interface automatically; bind an alternative
// in `module Test` to fake it. Column decoding is delegated to the injected
// sqlite.ColumnDecoder, so it can be rebound without touching this class.
import "std/ffi.xi"
import "std/json.xi"

class SystemSQLite implements sqlite.SQLite {
    deps { decoder: sqlite.ColumnDecoder }

    producer open(path: String) -> sqlite.Database! {
        let handle = empty Ptr
        let rc = sqlite3_open(toCString(path), &mut handle)
        if rc != SQLITE_OK() {
            let message = sqliteErrorOn(handle)
            let ignored = sqlite3_close(handle)
            return err(message)
        }
        return ok(sqlite.Database { handle: handle })
    }

    producer close(db: sqlite.Database) -> Bool! {
        let rc = sqlite3_close(db.handle)
        if rc != SQLITE_OK() { return err(sqliteErrorOn(db.handle)) }
        return ok(true)
    }

    // exec keeps sqlite3_exec so a single call may run several `;`-separated
    // statements (prepare_v2 would compile only the first).
    producer exec(db: sqlite.Database, sql: String) -> Bool! {
        let rc = sqlite3_exec(db.handle, toCString(sql), empty Ptr, empty Ptr, empty Ptr)
        if rc != SQLITE_OK() { return err(sqliteErrorOn(db.handle)) }
        return ok(true)
    }

    producer execBound(db: sqlite.Database, sql: String, params: Json) -> Bool! {
        let stmt = empty Ptr
        let rc = sqlite3_prepare_v2(db.handle, toCString(sql), -1, &mut stmt, empty Ptr)
        if rc != SQLITE_OK() { return err(sqliteErrorOn(db.handle)) }

        sqliteBindParams(stmt, params)
        loop {
            rc = sqlite3_step(stmt)
            if rc != SQLITE_ROW() { break }
        }

        if rc != SQLITE_DONE() {
            let message = sqliteErrorOn(db.handle)
            let ignored = sqlite3_finalize(stmt)
            return err(message)
        }

        let finalized = sqlite3_finalize(stmt)
        if finalized != SQLITE_OK() { return err(sqliteErrorOn(db.handle)) }
        return ok(true)
    }

    producer query(db: sqlite.Database, sql: String) -> sqlite.Rows! {
        return queryBound(db, sql, json.array())
    }

    producer queryBound(db: sqlite.Database, sql: String, params: Json) -> sqlite.Rows! {
        let stmt = empty Ptr
        let rc = sqlite3_prepare_v2(db.handle, toCString(sql), -1, &mut stmt, empty Ptr)
        if rc != SQLITE_OK() { return err(sqliteErrorOn(db.handle)) }

        sqliteBindParams(stmt, params)
        let rows = empty List<sqlite.Row>
        let cols = sqlite3_column_count(stmt)

        loop {
            rc = sqlite3_step(stmt)
            if rc != SQLITE_ROW() { break }

            let columns = empty Map<String, sqlite.Value>
            for col in 0 until cols {
                let name = sqliteOwnText(sqlite3_column_name(stmt, col))
                columns.put(name, decoder.decode(stmt, col))
            }
            rows.push(sqlite.Row { columns: columns })
        }

        if rc != SQLITE_DONE() {
            let message = sqliteErrorOn(db.handle)
            let ignored = sqlite3_finalize(stmt)
            return err(message)
        }

        let finalized = sqlite3_finalize(stmt)
        if finalized != SQLITE_OK() { return err(sqliteErrorOn(db.handle)) }
        return ok(sqlite.Rows { items: rows })
    }

    producer queryJson(db: sqlite.Database, sql: String) -> String! {
        let stmt = empty Ptr
        let rc = sqlite3_prepare_v2(db.handle, toCString(sql), -1, &mut stmt, empty Ptr)
        if rc != SQLITE_OK() { return err(sqliteErrorOn(db.handle)) }

        let out = json.array()
        let cols = sqlite3_column_count(stmt)

        loop {
            rc = sqlite3_step(stmt)
            if rc != SQLITE_ROW() { break }

            let obj = json.object()
            for col in 0 until cols {
                let name = sqliteOwnText(sqlite3_column_name(stmt, col))
                obj = json.set(obj, name, decoder.toJson(decoder.decode(stmt, col)))
            }
            out = json.push(out, obj)
        }

        if rc != SQLITE_DONE() {
            let message = sqliteErrorOn(db.handle)
            let ignored = sqlite3_finalize(stmt)
            return err(message)
        }

        let finalized = sqlite3_finalize(stmt)
        if finalized != SQLITE_OK() { return err(sqliteErrorOn(db.handle)) }
        return ok(json.stringify(out))
    }

    producer lastInsertId(db: sqlite.Database) -> Integer => sqlite3_last_insert_rowid(db.handle)

    producer changes(db: sqlite.Database) -> Integer => sqlite3_changes(db.handle)
}
