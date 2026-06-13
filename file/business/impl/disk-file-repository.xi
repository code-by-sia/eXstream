import "std/fs.xi"
import "std/path.xi"

// Folder-backed file storage: each stored file is a real file under the
// configured storage directory (config.fileStorageDir). The relative request
// path maps directly to a path inside that folder.
class DiskFileRepository implements FileRepository {
    deps { config: AppConfig, paths: FilePaths }

    producer list() -> List<String> {
        return walk(storageRoot(), "")
    }

    producer get(filePath: String) -> StoredFile {
        if not paths.isSafe(filePath) { return missingFile(filePath) }
        let target = storagePath(filePath)
        if not fs.isFile(target) { return missingFile(filePath) }

        let content = fs.readFile(target)
        if isErr(content) { return missingFile(filePath) }
        return StoredFile { found: true, path: filePath, content: content.value }
    }

    producer create(filePath: String, content: String) -> String {
        if not paths.isSafe(filePath) { return "invalid-path" }
        let target = storagePath(filePath)
        if fs.exists(target) { return "already-exists" }

        fs.mkdirAll(path.dirname(target))
        if fs.writeFile(target, content) { return "created" }
        return "storage-failed"
    }

    producer update(filePath: String, content: String) -> String {
        if not paths.isSafe(filePath) { return "invalid-path" }
        let target = storagePath(filePath)
        if not fs.isFile(target) { return "not-found" }

        fs.mkdirAll(path.dirname(target))
        if fs.writeFile(target, content) { return "updated" }
        return "storage-failed"
    }

    producer delete(filePath: String) -> String {
        if not paths.isSafe(filePath) { return "invalid-path" }
        let target = storagePath(filePath)
        if not fs.isFile(target) { return "not-found" }
        if fs.remove(target) { return "deleted" }
        return "storage-failed"
    }

    // Recursively lists relative file paths under `dir`, where `prefix` is the
    // path of `dir` relative to the storage root.
    producer walk(dir: String, prefix: String) -> List<String> {
        let out = empty List<String>
        let entries = fs.listDir(dir)
        let i = 0
        while i < entries.len {
            let name = entries.data[i]
            let full = path.join(dir, name)
            let rel = name
            if prefix != "" { rel = prefix + "/" + name }
            if fs.isDir(full) {
                for nested in walk(full, rel) { out.push(nested) }
            } else {
                out.push(rel)
            }
            i = i + 1
        }
        return out
    }

    producer storageRoot() -> String {
        let dir = path.join(fs.cwd(), config.fileStorageDir())
        fs.mkdirAll(dir)
        return dir
    }

    mapper storagePath(filePath: String) -> String {
        return path.join(path.join(fs.cwd(), config.fileStorageDir()), filePath)
    }

    mapper missingFile(filePath: String) -> StoredFile {
        return StoredFile { found: false, path: filePath, content: "" }
    }
}
