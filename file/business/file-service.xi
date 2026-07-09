// Application/use-case layer for stored files. The HTTP layer depends on this
// seam instead of FileRepository, so storage-key generation and persistence
// orchestration stay out of the controller. Implemented by FileManager.
//
// `read` and `store` return a StoredFile whose `found` flag signals success;
// create/update/delete return the repository's outcome string
// ("created" | "updated" | "deleted" | "not-found" | "already-exists" |
// "invalid-path").
interface FileService {
    producer list() -> List<String>
    producer read(filePath: String) -> StoredFile
    producer store(content: String) -> StoredFile
    producer create(filePath: String, content: String) -> String
    producer update(filePath: String, content: String) -> String
    producer delete(filePath: String) -> String
}
