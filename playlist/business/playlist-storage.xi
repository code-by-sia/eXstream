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

producer addTrack(id: String, title: String, artist: String, url: String, username: String) -> String {
    let content = readPlaylist(id)
    if text.isEmpty(content) { return "" }

    let trackId = crypto.randomHex(8)
    let line = trackId + "|" + cleanField(title) + "|" + cleanField(artist) + "|" + cleanField(url) + "|" + username
    if fs.writeFile(playlistPath(id), content + "\n" + line) { return trackId }
    return ""
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
