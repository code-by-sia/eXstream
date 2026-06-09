import "std/crypto.xi"
import "std/fs.xi"
import "std/text.xi"

producer readPlaylist(id: String) -> String {
    if not safeId(id) { return "" }
    let p = playlistPath(id)
    if not fs.isFile(p) { return "" }

    let content = fs.readFile(p)
    if isErr(content) { return "" }
    return content.value
}

producer createPlaylist(name: String, description: String, owner: String) -> String {
    playlistRoot()
    let id = crypto.randomHex(8)
    let body = cleanField(name) + "\n" + cleanField(description) + "\n" + owner
    if fs.writeFile(playlistPath(id), body) { return id }
    return ""
}

producer deletePlaylist(id: String) -> Bool {
    return fs.remove(playlistPath(id))
}

producer addTrack(id: String, title: String, artist: String, url: String, username: String, coverUrl: String) -> String {
    let content = readPlaylist(id)
    if text.isEmpty(content) { return "" }

    let trackId = crypto.randomHex(8)
    let line = trackLine(trackId, title, artist, url, username, coverUrl)
    if fs.writeFile(playlistPath(id), content + "\n" + line) { return trackId }
    return ""
}

producer updateTrack(id: String, trackId: String, title: String, artist: String, url: String, coverUrl: String) -> String {
    if not safeId(trackId) { return "invalid-id" }
    let content = readPlaylist(id)
    if text.isEmpty(content) { return "playlist-not-found" }

    let result = rewriteTrack(content, trackId, title, artist, url, coverUrl, false)
    if result == "not-found" { return result }
    if fs.writeFile(playlistPath(id), result) { return "updated" }
    return "storage-failed"
}

producer deleteTrack(id: String, trackId: String) -> String {
    if not safeId(trackId) { return "invalid-id" }
    let content = readPlaylist(id)
    if text.isEmpty(content) { return "playlist-not-found" }

    let result = rewriteTrack(content, trackId, "", "", "", "", true)
    if result == "not-found" { return result }
    if fs.writeFile(playlistPath(id), result) { return "deleted" }
    return "storage-failed"
}

producer listPlaylistsJson(username: String, role: String) -> String {
    let files = fs.listDir(playlistRoot())
    let out = "["
    let first = true
    let i = 0

    while i < files.len {
        let file = files.data[i]
        if text.endsWith(file, ".txt") {
            let id = text.substring(file, 0, text.length(file) - 4)
            let content = readPlaylist(id)
            if not text.isEmpty(content) and canAccess(content, username, role) {
                if not first { out = out + "," }
                first = false
                out = out + playlistJson(id, content)
            }
        }
        i = i + 1
    }
    return out + "]"
}

mapper trackLine(trackId: String, title: String, artist: String, url: String, addedBy: String, coverUrl: String) -> String {
    return trackId + "|" + cleanField(title) + "|" + cleanField(artist) + "|" + cleanField(url) + "|" + addedBy + "|" + cleanField(coverUrl)
}

mapper rewriteTrack(content: String, trackId: String, title: String, artist: String, url: String, coverUrl: String, remove: Bool) -> String {
    let lines = text.split(content, "\n")
    let out = lineOr(lines, 0) + "\n" + lineOr(lines, 1) + "\n" + lineOr(lines, 2)
    let found = false
    let i = 3

    while i < lines.len {
        let line = lines.data[i]
        let parts = text.split(line, "|")
        if parts.len >= 5 and parts.data[0] == trackId {
            found = true
            if not remove {
                out = out + "\n" + trackLine(trackId, title, artist, url, parts.data[4], coverUrl)
            }
        } else if not text.isEmpty(line) {
            out = out + "\n" + line
        }
        i = i + 1
    }

    if found { return out }
    return "not-found"
}
