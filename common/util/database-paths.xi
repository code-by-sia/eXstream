// Resolves a SQLite database file path under the configured data directory,
// creating the directory on demand. Implemented by FileDatabasePaths.
interface DatabasePaths {
    producer pathFor(name: String) -> String
}
