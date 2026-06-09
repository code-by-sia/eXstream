import "std/text.xi"
import "std/web.xi"
import "playlist-types.xi"
import "../business/playlists.xi"
import "../../common/security/auth-identity.xi"

class PlaylistApi implements WebRequestHandler {
    deps {}

    mapper getBaseUrl() -> String => "/"

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/health" {
        res.sendText(200, "{\"ok\":true,\"message\":\"playlist service up\"}")
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/playlists" and req.method == "GET" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        res.sendText(200, listPlaylistsJson(req.header("X-Username"), roleOf(req)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/playlists" and req.method == "POST" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let body = req.parse(PlaylistWrite)
        if text.isEmpty(body.name) { res.sendStatus(400, "playlist name is required") return }

        let id = createPlaylist(body.name, body.description, req.header("X-Username"))
        if text.isEmpty(id) { res.sendStatus(500, "failed to create playlist") return }
        res.sendText(200, playlistJson(id, readPlaylist(id)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/playlists/") and text.endsWith(req.path, "/tracks") and req.method == "POST" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let id = idFromPlaylistPath(req.path)
        let content = readPlaylist(id)
        if text.isEmpty(content) { res.sendStatus(404, "playlist not found") return }
        if not canAccess(content, req.header("X-Username"), roleOf(req)) { res.sendStatus(403, "playlist access denied") return }

        let body = req.parse(TrackWrite)
        if text.isEmpty(body.title) or text.isEmpty(body.url) { res.sendStatus(400, "title and url are required") return }

        let trackId = addTrack(id, body.title, body.artist, body.url, req.header("X-Username"))
        if text.isEmpty(trackId) { res.sendStatus(500, "failed to add track") return }
        res.sendText(200, playlistJson(id, readPlaylist(id)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/playlists/") and text.contains(req.path, "/tracks/") and req.method == "PUT" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let id = idFromPlaylistPath(req.path)
        let content = readPlaylist(id)
        if text.isEmpty(content) { res.sendStatus(404, "playlist not found") return }
        if not canAccess(content, req.header("X-Username"), roleOf(req)) { res.sendStatus(403, "playlist access denied") return }

        let body = req.parse(TrackWrite)
        if text.isEmpty(body.title) or text.isEmpty(body.url) { res.sendStatus(400, "title and url are required") return }

        let result = updateTrack(id, trackIdFromTrackPath(req.path), body.title, body.artist, body.url)
        sendTrackWriteResult(res, id, result)
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/playlists/") and text.contains(req.path, "/tracks/") and req.method == "DELETE" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let id = idFromPlaylistPath(req.path)
        let content = readPlaylist(id)
        if text.isEmpty(content) { res.sendStatus(404, "playlist not found") return }
        if not canAccess(content, req.header("X-Username"), roleOf(req)) { res.sendStatus(403, "playlist access denied") return }

        let result = deleteTrack(id, trackIdFromTrackPath(req.path))
        sendTrackWriteResult(res, id, result)
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/playlists/") and req.method == "GET" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        sendPlaylist(req, res, idFromPlaylistPath(req.path))
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/playlists/") and req.method == "DELETE" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let id = idFromPlaylistPath(req.path)
        let content = readPlaylist(id)
        if text.isEmpty(content) { res.sendStatus(404, "playlist not found") return }
        if not canAccess(content, req.header("X-Username"), roleOf(req)) { res.sendStatus(403, "playlist access denied") return }

        if deletePlaylist(id) { res.sendText(200, "{\"ok\":true,\"message\":\"deleted\"}") } else { res.sendStatus(500, "failed to delete playlist") }
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/playlist/search" and req.method == "GET" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        res.sendText(200, searchPlaylistsJson(req.query("q"), req.header("X-Username"), roleOf(req)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/music/search" and req.method == "GET" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        res.sendText(200, searchMusicJson(req.query("q"), req.header("X-Username"), roleOf(req)))
    }

    action handle(req: HttpRequest, res: HttpResponse) {
        res.sendStatus(404, "Not Found")
    }
}

consumer sendPlaylist(req: HttpRequest, res: HttpResponse, id: String) {
    let content = readPlaylist(id)
    if text.isEmpty(content) { res.sendStatus(404, "playlist not found") return }
    if not canAccess(content, req.header("X-Username"), roleOf(req)) { res.sendStatus(403, "playlist access denied") return }
    res.sendText(200, playlistJson(id, content))
}

consumer sendTrackWriteResult(res: HttpResponse, id: String, result: String) {
    if result == "updated" or result == "deleted" {
        res.sendText(200, playlistJson(id, readPlaylist(id)))
        return
    }
    if result == "not-found" { res.sendStatus(404, "track not found") return }
    if result == "invalid-id" { res.sendStatus(400, "invalid track id") return }
    res.sendStatus(500, "failed to write track")
}
