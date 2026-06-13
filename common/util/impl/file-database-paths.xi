import "std/fs.xi"
import "std/path.xi"

class FileDatabasePaths implements DatabasePaths {
    deps { config: AppConfig }

    producer pathFor(name: String) -> String {
        let dir = path.join(fs.cwd(), config.dataDir())
        fs.mkdirAll(dir)
        return path.join(dir, name)
    }
}
