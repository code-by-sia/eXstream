import "std/fs.xi"
import "std/text.xi"

producer searchPlaylistsJson(query: String, username: String, role: String) -> String {
    let q = text.toLower(query)
    let files = fs.listDir(playlistRoot())
    let out = "["
    let first = true
    let i = 0

    while i < files.len {
        let file = files.data[i]
        if text.endsWith(file, ".txt") {
            let id = text.substring(file, 0, text.length(file) - 4)
            let content = readPlaylist(id)
            let lower = text.toLower(content)
            if not text.isEmpty(content) and canAccess(content, username, role) and (text.isEmpty(q) or text.contains(lower, q)) {
                if not first { out = out + "," }
                first = false
                out = out + playlistJson(id, content)
            }
        }
        i = i + 1
    }
    return out + "]"
}

producer searchMusicJson(query: String, username: String, role: String) -> String {
    let q = text.toLower(query)
    let files = fs.listDir(playlistRoot())
    let out = "["
    let first = true
    let i = 0

    while i < files.len {
        let file = files.data[i]
        if text.endsWith(file, ".txt") {
            let playlistId = text.substring(file, 0, text.length(file) - 4)
            let content = readPlaylist(playlistId)
            if not text.isEmpty(content) and canAccess(content, username, role) {
                out = appendMusicMatches(out, first, q, playlistId, content)
                first = false
            }
        }
        i = i + 1
    }
    return out + "]"
}

mapper appendMusicMatches(out: String, first: Bool, q: String, playlistId: String, content: String) -> String {
    let result = out
    let isFirst = first
    let lines = text.split(content, "\n")
    let j = 3

    while j < lines.len {
        let parts = text.split(lines.data[j], "|")
        if parts.len >= 5 {
            let haystack = text.toLower(parts.data[1] + " " + parts.data[2])
            if text.isEmpty(q) or text.contains(haystack, q) {
                if not isFirst { result = result + "," }
                isFirst = false
                result = result + "{"
                    + "\"id\":" + jsonString(parts.data[0]) + ","
                    + "\"playlistId\":" + jsonString(playlistId) + ","
                    + "\"title\":" + jsonString(parts.data[1]) + ","
                    + "\"artist\":" + jsonString(parts.data[2]) + ","
                    + "\"url\":" + jsonString(parts.data[3]) + ","
                    + "\"addedBy\":" + jsonString(parts.data[4])
                    + "}"
            }
        }
        j = j + 1
    }
    return result
}
