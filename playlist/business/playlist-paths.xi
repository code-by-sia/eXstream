import "std/fs.xi"
import "std/path.xi"
import "std/text.xi"

producer playlistRoot() -> String {
    let d = path.join(fs.cwd(), "data/playlists")
    fs.mkdirAll(d)
    return d
}

mapper playlistPath(id: String) -> String {
    return path.join(path.join(fs.cwd(), "data/playlists"), id + ".txt")
}

mapper idFromPlaylistPath(reqPath: String) -> String {
    let rest = text.substring(reqPath, 11, text.length(reqPath))
    let slash = text.indexOf(rest, "/")
    if slash >= 0 { return text.substring(rest, 0, slash) }
    return rest
}

predicate safeId(id: String) {
    if text.isEmpty(id) { return false }
    if text.contains(id, "/") { return false }
    if text.contains(id, "\\") { return false }
    if text.contains(id, "..") { return false }
    return true
}
