import "std/text.xi"

// SQLite has no parameter binding in xi-sqlite, so single quotes in string
// literals are escaped by doubling them. Keep every SQL string value wrapped
// in escapeSql(...) to stay injection-safe.
mapper escapeSql(s: String) -> String {
    return text.replace(s, "'", "''")
}
