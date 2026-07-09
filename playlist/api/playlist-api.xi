import "std/text.xi"
import "std/web.xi"

class PlaylistApi implements WebRequestHandler {
    deps {
        playlists: PlaylistRepository
        identity: AuthIdentity
        presenter: PlaylistPresenter
        paths: PlaylistPaths
        access: PlaylistAccess
    }

    mapper getBaseUrl() -> String => "/"

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/health" {
        res.send(PlaylistMessage { ok: true, message: "playlist service up" })
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/playlists") {
        if not requireIdentity(req, res) { return }
        res.sendText(200, presenter.playlists(playlists.listForUser(actor(req), identity.roleOf(req))))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "POST", "/playlists") {
        if not requireIdentity(req, res) { return }

        let body = web.body(req) as PlaylistWrite
        if text.isEmpty(body.name) { res.sendStatus(400, "playlist name is required") return }

        let id = playlists.create(body.name, body.description, actor(req))
        if text.isEmpty(id) { res.sendStatus(500, "failed to create playlist") return }
        res.sendText(200, presenter.playlist(playlists.get(id)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "POST", "/playlists/:playlistId/tracks") {
        let playlist = accessiblePlaylist(req, res)
        if not playlist.found { return }

        let body = web.body(req) as TrackWrite
        if text.isEmpty(body.title) or text.isEmpty(body.url) { res.sendStatus(400, "title and url are required") return }

        let trackId = playlists.addTrack(playlist.id, body.title, body.artist, body.url, actor(req), body.coverUrl)
        if text.isEmpty(trackId) { res.sendStatus(500, "failed to add track") return }
        res.sendText(200, presenter.playlist(playlists.get(playlist.id)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "PUT", "/playlists/:playlistId/tracks") {
        let playlist = accessiblePlaylist(req, res)
        if not playlist.found { return }

        let trackId = safeTrackId(req, res)
        if text.isEmpty(trackId) { return }

        let body = web.body(req) as TrackWrite
        if text.isEmpty(body.title) or text.isEmpty(body.url) { res.sendStatus(400, "title and url are required") return }

        sendTrackWriteResult(res, playlist.id, playlists.updateTrack(playlist.id, trackId, body.title, body.artist, body.url, body.coverUrl))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "POST", "/playlists/:playlistId/tracks/:trackId/move") {
        let source = accessiblePlaylist(req, res)
        if not source.found { return }

        let trackId = safeTrackId(req, res)
        if text.isEmpty(trackId) { return }

        let body = web.body(req) as TrackMove
        let target = playlists.get(body.targetPlaylistId)
        if not target.found { res.sendStatus(404, "target playlist not found") return }
        if not access.canAccess(target, actor(req), identity.roleOf(req)) { res.sendStatus(403, "target playlist access denied") return }

        sendTrackWriteResult(res, target.id, playlists.moveTrack(source.id, trackId, target.id))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "DELETE", "/playlists/:playlistId/tracks/:trackId") {
        let playlist = accessiblePlaylist(req, res)
        if not playlist.found { return }

        let trackId = safeTrackId(req, res)
        if text.isEmpty(trackId) { return }

        sendTrackWriteResult(res, playlist.id, playlists.deleteTrack(playlist.id, trackId))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/playlists/:id") {
        let playlist = accessiblePlaylist(req, res)
        if not playlist.found { return }
        res.sendText(200, presenter.playlist(playlist))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "DELETE", "/playlists/:id") {
        let playlist = accessiblePlaylist(req, res)
        if not playlist.found { return }

        if playlists.remove(playlist.id) {
            res.send(PlaylistMessage { ok: true, message: "deleted" })
        } else {
            res.sendStatus(500, "failed to delete playlist")
        }
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/playlist/search") {
        if not requireIdentity(req, res) { return }
        res.sendText(200, presenter.playlists(playlists.searchPlaylists(req.query("q"), actor(req), identity.roleOf(req))))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/music/search") {
        if not requireIdentity(req, res) { return }
        res.sendText(200, presenter.musicHits(playlists.searchTracks(req.query("q"), actor(req), identity.roleOf(req))))
    }

    action handle(req: HttpRequest, res: HttpResponse) {
        res.sendStatus(404, "Not Found")
    }

    // --- request guards: one place each for identity, access, and id checks ---

    // Ensures identity headers are present; writes 403 and returns false if not.
    producer requireIdentity(req: HttpRequest, res: HttpResponse) -> Bool {
        if identity.hasIdentity(req) { return true }
        res.sendStatus(403, "missing identity headers")
        return false
    }

    // Resolves the playlist named in the path and confirms the caller may touch
    // it. On any failure it writes the response (403/404) and returns a
    // not-found playlist so the handler can bail with `if not p.found { return }`.
    producer accessiblePlaylist(req: HttpRequest, res: HttpResponse) -> Playlist {
        if not identity.hasIdentity(req) {
            res.sendStatus(403, "missing identity headers")
            return noPlaylist()
        }
        let playlist = playlists.get(paths.playlistId(req.path))
        if not playlist.found {
            res.sendStatus(404, "playlist not found")
            return noPlaylist()
        }
        if not access.canAccess(playlist, actor(req), identity.roleOf(req)) {
            res.sendStatus(403, "playlist access denied")
            return noPlaylist()
        }
        return playlist
    }

    // Extracts and validates the track id from the path; writes 400 and returns
    // "" if it is unsafe.
    producer safeTrackId(req: HttpRequest, res: HttpResponse) -> String {
        let trackId = paths.trackId(req.path)
        if paths.isSafeId(trackId) { return trackId }
        res.sendStatus(400, "invalid track id")
        return ""
    }

    mapper actor(req: HttpRequest) -> String => req.header("X-Username")

    mapper noPlaylist() -> Playlist {
        return Playlist { found: false, id: "", name: "", description: "", owner: "", tracks: empty List<Track> }
    }

    consumer sendTrackWriteResult(res: HttpResponse, id: String, result: String) {
        if result == "updated" or result == "deleted" or result == "moved" {
            res.sendText(200, presenter.playlist(playlists.get(id)))
            return
        }
        if result == "not-found" { res.sendStatus(404, "track not found") return }
        res.sendStatus(500, "failed to write track")
    }
}
