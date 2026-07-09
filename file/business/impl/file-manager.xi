import "std/crypto.xi"

// Orchestrates file use-cases over the repository. Owns the storage-key scheme
// for uploads (music/<uuid>) so the HTTP layer never invents storage paths.
class FileManager implements FileService {
    deps { files: FileRepository }

    producer list() -> List<String> {
        return files.list()
    }

    producer read(filePath: String) -> StoredFile {
        return files.get(filePath)
    }

    producer store(content: String) -> StoredFile {
        let filePath = "music/" + newUuid()
        if files.create(filePath, content) == "created" {
            return StoredFile { found: true, path: filePath, content: content }
        }
        return StoredFile { found: false, path: "", content: "" }
    }

    producer create(filePath: String, content: String) -> String {
        return files.create(filePath, content)
    }

    producer update(filePath: String, content: String) -> String {
        return files.update(filePath, content)
    }

    producer delete(filePath: String) -> String {
        return files.delete(filePath)
    }

    mapper newUuid() -> String {
        return crypto.randomHex(4) + "-"
            + crypto.randomHex(2) + "-"
            + crypto.randomHex(2) + "-"
            + crypto.randomHex(2) + "-"
            + crypto.randomHex(6)
    }
}
