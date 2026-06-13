import "std/web.xi"

// Extracts the stored file path from a request URL and validates it stays
// within the storage folder. Implemented by RequestFilePaths.
interface FilePaths {
    mapper fromRequest(req: HttpRequest) -> String
    predicate isSafe(filePath: String)
}
