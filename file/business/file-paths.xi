import "std/text.xi"
import "std/web.xi"

mapper requestFilePath(req: HttpRequest) -> String {
    return text.substring(req.path, 6, text.length(req.path))
}

predicate safePath(filePath: String) {
    if text.isEmpty(filePath) { return false }
    if text.startsWith(filePath, "/") { return false }
    if text.endsWith(filePath, "/") { return false }
    if text.contains(filePath, "\\") { return false }
    if text.contains(filePath, "..") { return false }
    return true
}
