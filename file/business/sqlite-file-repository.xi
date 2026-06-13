import "std/text.xi"
import "file-paths.xi"
import "../../common/util/sql-text.xi"
import "../../common/util/sqlite-db.xi"
import "../../vendor/sqlite.xi"

// Opens the file database and guarantees the schema exists. Opened per
// operation; the caller closes the returned connection.
producer (sql: sqlite.SQLite) connectFiles() -> sqlite.Database! {
    let db = sql.open(dbPath("files.db"))?
    sql.exec(db, "create table if not exists files ("
        + "path text primary key,"
        + "content text not null)")?
    return ok(db)
}

class SqliteFileRepository implements FileRepository {
    deps { sql: sqlite.SQLite, reader: sqlite.RowReader }

    producer list() -> List<String> {
        let paths = empty List<String>
        let opened = connectFiles()
        if isErr(opened) { return paths }
        let db = opened.value

        let rows = sql.query(db, "select path from files order by path")
        if isOk(rows) {
            for row in rows.value.items {
                paths.push(reader.textAt(row, "path", ""))
            }
        }
        sql.close(db)
        return paths
    }

    producer get(filePath: String) -> StoredFile {
        if not safePath(filePath) { return missingFile(filePath) }
        let opened = connectFiles()
        if isErr(opened) { return missingFile(filePath) }
        let db = opened.value

        let rows = sql.query(db, "select path, content from files where path = '" + escapeSql(filePath) + "'")
        if isErr(rows) or rows.value.items.isEmpty() { sql.close(db) return missingFile(filePath) }

        let row = rows.value.items.get(0)
        let stored = StoredFile { found: true, path: reader.textAt(row, "path", filePath), content: reader.textAt(row, "content", "") }
        sql.close(db)
        return stored
    }

    producer create(filePath: String, content: String) -> String {
        if not safePath(filePath) { return "invalid-path" }
        let opened = connectFiles()
        if isErr(opened) { return "storage-failed" }
        let db = opened.value

        let written = sql.exec(db, "insert into files (path, content) values ("
            + "'" + escapeSql(filePath) + "', '" + escapeSql(content) + "')")
        sql.close(db)
        if isErr(written) { return "already-exists" }
        return "created"
    }

    producer update(filePath: String, content: String) -> String {
        if not safePath(filePath) { return "invalid-path" }
        let opened = connectFiles()
        if isErr(opened) { return "storage-failed" }
        let db = opened.value

        let written = sql.exec(db, "update files set content = '" + escapeSql(content) + "' where path = '" + escapeSql(filePath) + "'")
        if isErr(written) { sql.close(db) return "storage-failed" }
        if sql.changes(db) == 0 { sql.close(db) return "not-found" }
        sql.close(db)
        return "updated"
    }

    producer delete(filePath: String) -> String {
        if not safePath(filePath) { return "invalid-path" }
        let opened = connectFiles()
        if isErr(opened) { return "storage-failed" }
        let db = opened.value

        let written = sql.exec(db, "delete from files where path = '" + escapeSql(filePath) + "'")
        if isErr(written) { sql.close(db) return "storage-failed" }
        if sql.changes(db) == 0 { sql.close(db) return "not-found" }
        sql.close(db)
        return "deleted"
    }
}

mapper missingFile(filePath: String) -> StoredFile {
    return StoredFile { found: false, path: filePath, content: "" }
}
