import "std/text.xi"
import "std/web.xi"

class PlaylistApi implements WebRequestHandler {
    deps {
        service: PlaylistService
        identity: AuthIdentity
        presenter: PlaylistPresenter
        paths: PlaylistPaths
    }

    mapper getBaseUrl() -> String => "/"

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/health" {
        res.send(PlaylistMessage { ok: true, message: "playlist service up" })
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/playlists") {
        if not requireIdentity(req, res) { return }
        res.sendText(200, presenter.playlists(service.listFor(actor(req), identity.roleOf(req))))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "POST", "/playlists") {
        if not requireIdentity(req, res) { return }

        let body = web.body(req) as PlaylistWrite
        if text.isEmpty(body.name) { res.sendStatus(400, "playlist name is required") return }

        let created = service.create(body.name, body.description, actor(req))
        if not created.found { res.sendStatus(500, "failed to create playlist") return }
        res.sendText(200, presenter.playlist(created))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "POST", "/playlists/:playlistId/tracks") {
        if not requireIdentity(req, res) { return }

        let body = web.body(req) as TrackWrite
        if text.isEmpty(body.title) or text.isEmpty(body.url) { res.sendStatus(400, "title and url are required") return }

        let result = service.addTrack(paths.playlistId(req.path), body.title, body.artist, body.url, actor(req), identity.roleOf(req), body.coverUrl)
        if result.status == "failed" { res.sendStatus(500, "failed to add track") return }
        if not resolved(res, result) { return }
        res.sendText(200, presenter.playlist(result.playlist))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "PUT", "/playlists/:playlistId/tracks") {
        if not requireIdentity(req, res) { return }

        let trackId = safeTrackId(req, res)
        if text.isEmpty(trackId) { return }

        let body = web.body(req) as TrackWrite
        if text.isEmpty(body.title) or text.isEmpty(body.url) { res.sendStatus(400, "title and url are required") return }

        finishTrackWrite(res, service.updateTrack(paths.playlistId(req.path), trackId, body.title, body.artist, body.url, body.coverUrl, actor(req), identity.roleOf(req)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "POST", "/playlists/:playlistId/tracks/:trackId/move") {
        if not requireIdentity(req, res) { return }

        let trackId = safeTrackId(req, res)
        if text.isEmpty(trackId) { return }

        let body = web.body(req) as TrackMove
        finishTrackWrite(res, service.moveTrack(paths.playlistId(req.path), trackId, body.targetPlaylistId, actor(req), identity.roleOf(req)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "DELETE", "/playlists/:playlistId/tracks/:trackId") {
        if not requireIdentity(req, res) { return }

        let trackId = safeTrackId(req, res)
        if text.isEmpty(trackId) { return }

        finishTrackWrite(res, service.deleteTrack(paths.playlistId(req.path), trackId, actor(req), identity.roleOf(req)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/playlists/:id") {
        if not requireIdentity(req, res) { return }

        let result = service.view(paths.playlistId(req.path), actor(req), identity.roleOf(req))
        if not resolved(res, result) { return }
        res.sendText(200, presenter.playlist(result.playlist))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "DELETE", "/playlists/:id") {
        if not requireIdentity(req, res) { return }

        let result = service.remove(paths.playlistId(req.path), actor(req), identity.roleOf(req))
        if result.status == "failed" { res.sendStatus(500, "failed to delete playlist") return }
        if not resolved(res, result) { return }
        res.send(PlaylistMessage { ok: true, message: "deleted" })
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/playlist/search") {
        if not requireIdentity(req, res) { return }
        res.sendText(200, presenter.playlists(service.search(req.query("q"), actor(req), identity.roleOf(req))))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/music/search") {
        if not requireIdentity(req, res) { return }
        res.sendText(200, presenter.musicHits(service.searchTracks(req.query("q"), actor(req), identity.roleOf(req))))
    }

    action handle(req: HttpRequest, res: HttpResponse) {
        res.sendStatus(404, "Not Found")
    }

    // --- HTTP guards & outcome mapping (no repository access lives here) ---

    // Ensures identity headers are present; writes 403 and returns false if not.
    producer requireIdentity(req: HttpRequest, res: HttpResponse) -> Bool {
        if identity.hasIdentity(req) { return true }
        res.sendStatus(403, "missing identity headers")
        return false
    }

    // Extracts and validates the track id from the path; writes 400 and returns
    // "" if it is unsafe.
    producer safeTrackId(req: HttpRequest, res: HttpResponse) -> String {
        let trackId = paths.trackId(req.path)
        if paths.isSafeId(trackId) { return trackId }
        res.sendStatus(400, "invalid track id")
        return ""
    }

    // Translates a non-"ok" service result to its HTTP error; returns true only
    // when the caller may proceed.
    producer resolved(res: HttpResponse, result: PlaylistResult) -> Bool {
        if result.status == "ok" { return true }
        if result.status == "not-found" { res.sendStatus(404, "playlist not found") return false }
        if result.status == "denied" { res.sendStatus(403, "playlist access denied") return false }
        if result.status == "track-not-found" { res.sendStatus(404, "track not found") return false }
        if result.status == "target-not-found" { res.sendStatus(404, "target playlist not found") return false }
        if result.status == "target-denied" { res.sendStatus(403, "target playlist access denied") return false }
        res.sendStatus(500, "failed to write track")
        return false
    }

    consumer finishTrackWrite(res: HttpResponse, result: PlaylistResult) {
        if resolved(res, result) { res.sendText(200, presenter.playlist(result.playlist)) }
    }

    mapper actor(req: HttpRequest) -> String => req.header("X-Username")
}
