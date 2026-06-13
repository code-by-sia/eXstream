import "std/text.xi"
import "std/web.xi"
import "playlist-types.xi"
import "../business/playlists.xi"
import "../../common/security/auth-identity.xi"

class PlaylistApi implements WebRequestHandler {
    deps { playlists: PlaylistRepository }

    mapper getBaseUrl() -> String => "/"

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/health" {
        res.sendText(200, "{\"ok\":true,\"message\":\"playlist service up\"}")
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/playlists" and req.method == "GET" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        res.sendText(200, playlistsJson(playlists.listForUser(req.header("X-Username"), roleOf(req))))
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/playlists" and req.method == "POST" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let body = req.parse(PlaylistWrite)
        if text.isEmpty(body.name) { res.sendStatus(400, "playlist name is required") return }

        let id = playlists.create(body.name, body.description, req.header("X-Username"))
        if text.isEmpty(id) { res.sendStatus(500, "failed to create playlist") return }
        res.sendText(200, playlistJson(playlists.get(id)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/playlists/") and text.endsWith(req.path, "/tracks") and req.method == "POST" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let playlist = playlists.get(idFromPlaylistPath(req.path))
        if not playlist.found { res.sendStatus(404, "playlist not found") return }
        if not canAccessPlaylist(playlist, req.header("X-Username"), roleOf(req)) { res.sendStatus(403, "playlist access denied") return }

        let body = req.parse(TrackWrite)
        if text.isEmpty(body.title) or text.isEmpty(body.url) { res.sendStatus(400, "title and url are required") return }

        let trackId = playlists.addTrack(playlist.id, body.title, body.artist, body.url, req.header("X-Username"), body.coverUrl)
        if text.isEmpty(trackId) { res.sendStatus(500, "failed to add track") return }
        res.sendText(200, playlistJson(playlists.get(playlist.id)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/playlists/") and text.contains(req.path, "/tracks/") and req.method == "PUT" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let playlist = playlists.get(idFromPlaylistPath(req.path))
        if not playlist.found { res.sendStatus(404, "playlist not found") return }
        if not canAccessPlaylist(playlist, req.header("X-Username"), roleOf(req)) { res.sendStatus(403, "playlist access denied") return }

        let trackId = trackIdFromTrackPath(req.path)
        if not safeId(trackId) { res.sendStatus(400, "invalid track id") return }

        let body = req.parse(TrackWrite)
        if text.isEmpty(body.title) or text.isEmpty(body.url) { res.sendStatus(400, "title and url are required") return }

        let result = playlists.updateTrack(playlist.id, trackId, body.title, body.artist, body.url, body.coverUrl)
        sendTrackWriteResult(res, playlists, playlist.id, result)
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/playlists/") and text.contains(req.path, "/tracks/") and req.method == "DELETE" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let playlist = playlists.get(idFromPlaylistPath(req.path))
        if not playlist.found { res.sendStatus(404, "playlist not found") return }
        if not canAccessPlaylist(playlist, req.header("X-Username"), roleOf(req)) { res.sendStatus(403, "playlist access denied") return }

        let trackId = trackIdFromTrackPath(req.path)
        if not safeId(trackId) { res.sendStatus(400, "invalid track id") return }

        let result = playlists.deleteTrack(playlist.id, trackId)
        sendTrackWriteResult(res, playlists, playlist.id, result)
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/playlists/") and req.method == "GET" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let playlist = playlists.get(idFromPlaylistPath(req.path))
        if not playlist.found { res.sendStatus(404, "playlist not found") return }
        if not canAccessPlaylist(playlist, req.header("X-Username"), roleOf(req)) { res.sendStatus(403, "playlist access denied") return }
        res.sendText(200, playlistJson(playlist))
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/playlists/") and req.method == "DELETE" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let playlist = playlists.get(idFromPlaylistPath(req.path))
        if not playlist.found { res.sendStatus(404, "playlist not found") return }
        if not canAccessPlaylist(playlist, req.header("X-Username"), roleOf(req)) { res.sendStatus(403, "playlist access denied") return }

        if playlists.remove(playlist.id) { res.sendText(200, "{\"ok\":true,\"message\":\"deleted\"}") } else { res.sendStatus(500, "failed to delete playlist") }
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/playlist/search" and req.method == "GET" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        res.sendText(200, playlistsJson(playlists.searchPlaylists(req.query("q"), req.header("X-Username"), roleOf(req))))
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/music/search" and req.method == "GET" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        res.sendText(200, musicHitsJson(playlists.searchTracks(req.query("q"), req.header("X-Username"), roleOf(req))))
    }

    action handle(req: HttpRequest, res: HttpResponse) {
        res.sendStatus(404, "Not Found")
    }
}

consumer sendTrackWriteResult(res: HttpResponse, repo: PlaylistRepository, id: String, result: String) {
    if result == "updated" or result == "deleted" {
        res.sendText(200, playlistJson(repo.get(id)))
        return
    }
    if result == "not-found" { res.sendStatus(404, "track not found") return }
    res.sendStatus(500, "failed to write track")
}
