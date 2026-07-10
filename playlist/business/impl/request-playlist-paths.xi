import "std/text.xi"

class RequestPlaylistPaths implements PlaylistPaths {
    deps {}

    mapper playlistId(reqPath: String) -> String {
        let rest = text.substring(reqPath, 11, text.length(reqPath))
        let slash = text.indexOf(rest, "/")
        if slash >= 0 { return text.substring(rest, 0, slash) }
        return rest
    }

    mapper trackId(reqPath: String) -> String {
        let prefix = $"/playlists/${playlistId(reqPath)}/tracks/"
        if not text.startsWith(reqPath, prefix) { return "" }
        let rest = text.substring(reqPath, text.length(prefix), text.length(reqPath))
        let slash = text.indexOf(rest, "/")
        if slash >= 0 { return text.substring(rest, 0, slash) }
        return rest
    }

    predicate isSafeId(id: String) {
        if text.isEmpty(id) { return false }
        if text.contains(id, "/") { return false }
        if text.contains(id, "\\") { return false }
        if text.contains(id, "..") { return false }
        return true
    }
}
