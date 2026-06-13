import "std/fs.xi"
import "std/path.xi"

// Resolves a database file under ./data, creating the directory on demand.
// Each service passes its own file name (e.g. "auth.db").
producer dbPath(name: String) -> String {
    let dir = path.join(fs.cwd(), "data")
    fs.mkdirAll(dir)
    return path.join(dir, name)
}
