type StoredFile = { found: Bool, path: String, content: String }

interface FileRepository {
    producer list() -> List<String>
    producer get(filePath: String) -> StoredFile
    producer create(filePath: String, content: String) -> String
    producer update(filePath: String, content: String) -> String
    producer delete(filePath: String) -> String
}
