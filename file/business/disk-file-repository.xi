import "std/fs.xi"
import "std/path.xi"
import "file-paths.xi"

class DiskFileRepository implements FileRepository {
    deps {}

    producer list() -> String[] {
        return fs.listDir(storageRoot())
    }

    producer get(filePath: String) -> StoredFile {
        if not safePath(filePath) { return StoredFile { path: filePath, content: "" } }
        let target = storagePath(filePath)
        if not fs.isFile(target) { return StoredFile { path: filePath, content: "" } }

        let content = fs.readFile(target)
        if isErr(content) { return StoredFile { path: filePath, content: "" } }
        return StoredFile { path: filePath, content: content.value }
    }

    producer create(filePath: String, content: String) -> String {
        if not safePath(filePath) { return "invalid-path" }
        let target = storagePath(filePath)
        if fs.exists(target) { return "already-exists" }

        fs.mkdirAll(path.dirname(target))
        if fs.writeFile(target, content) { return "created" }
        return "storage-failed"
    }

    producer update(filePath: String, content: String) -> String {
        if not safePath(filePath) { return "invalid-path" }
        let target = storagePath(filePath)
        if not fs.isFile(target) { return "not-found" }

        fs.mkdirAll(path.dirname(target))
        if fs.writeFile(target, content) { return "updated" }
        return "storage-failed"
    }

    producer delete(filePath: String) -> String {
        if not safePath(filePath) { return "invalid-path" }
        let target = storagePath(filePath)
        if not fs.isFile(target) { return "not-found" }
        if fs.remove(target) { return "deleted" }
        return "storage-failed"
    }
}
