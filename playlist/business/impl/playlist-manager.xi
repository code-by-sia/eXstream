import "std/text.xi"

// Orchestrates the playlist use-cases over the repository and the access
// policy. Every mutating path first resolves the playlist and confirms the
// caller may touch it (authorize), so callers cannot bypass access control.
class PlaylistManager implements PlaylistService {
    deps { playlists: PlaylistRepository, access: PlaylistAccess }

    producer listFor(username: String, role: String) -> List<Playlist> {
        return playlists.listForUser(username, role)
    }

    producer search(query: String, username: String, role: String) -> List<Playlist> {
        return playlists.searchPlaylists(query, username, role)
    }

    producer searchTracks(query: String, username: String, role: String) -> List<MusicHit> {
        return playlists.searchTracks(query, username, role)
    }

    producer create(name: String, description: String, owner: String) -> Playlist {
        let id = playlists.create(name, description, owner)
        if text.isEmpty(id) { return noPlaylist() }
        return playlists.get(id)
    }

    producer view(id: String, username: String, role: String) -> PlaylistResult {
        return authorize(id, username, role)
    }

    producer remove(id: String, username: String, role: String) -> PlaylistResult {
        let gate = authorize(id, username, role)
        if gate.status != "ok" { return gate }
        if playlists.remove(gate.playlist.id) { return okResult(gate.playlist) }
        return failed()
    }

    producer addTrack(id: String, title: String, artist: String, url: String, username: String, role: String, coverUrl: String) -> PlaylistResult {
        let gate = authorize(id, username, role)
        if gate.status != "ok" { return gate }
        let trackId = playlists.addTrack(gate.playlist.id, title, artist, url, username, coverUrl)
        if text.isEmpty(trackId) { return failed() }
        return okResult(playlists.get(gate.playlist.id))
    }

    producer updateTrack(id: String, trackId: String, title: String, artist: String, url: String, coverUrl: String, username: String, role: String) -> PlaylistResult {
        let gate = authorize(id, username, role)
        if gate.status != "ok" { return gate }
        return writeResult(gate.playlist.id, playlists.updateTrack(gate.playlist.id, trackId, title, artist, url, coverUrl))
    }

    producer deleteTrack(id: String, trackId: String, username: String, role: String) -> PlaylistResult {
        let gate = authorize(id, username, role)
        if gate.status != "ok" { return gate }
        return writeResult(gate.playlist.id, playlists.deleteTrack(gate.playlist.id, trackId))
    }

    producer moveTrack(sourceId: String, trackId: String, targetId: String, username: String, role: String) -> PlaylistResult {
        let source = authorize(sourceId, username, role)
        if source.status != "ok" { return source }

        let target = playlists.get(targetId)
        if not target.found { return result("target-not-found", noPlaylist()) }
        if not access.canAccess(target, username, role) { return result("target-denied", noPlaylist()) }

        return writeResult(target.id, playlists.moveTrack(source.playlist.id, trackId, target.id))
    }

    // Resolves a playlist and confirms the caller may access it.
    producer authorize(id: String, username: String, role: String) -> PlaylistResult {
        let playlist = playlists.get(id)
        if not playlist.found { return result("not-found", noPlaylist()) }
        if not access.canAccess(playlist, username, role) { return result("denied", noPlaylist()) }
        return okResult(playlist)
    }

    // Maps a repository write-result string to a PlaylistResult, refreshing the
    // playlist on success.
    producer writeResult(id: String, outcome: String) -> PlaylistResult {
        if outcome == "updated" or outcome == "deleted" or outcome == "moved" { return okResult(playlists.get(id)) }
        if outcome == "not-found" { return result("track-not-found", noPlaylist()) }
        return failed()
    }

    mapper okResult(item: Playlist) -> PlaylistResult => result("ok", item)
    mapper failed() -> PlaylistResult => result("failed", noPlaylist())
    mapper result(status: String, item: Playlist) -> PlaylistResult {
        return PlaylistResult { status: status, playlist: item }
    }
    mapper noPlaylist() -> Playlist {
        return Playlist { found: false, id: "", name: "", description: "", owner: "", tracks: empty List<Track> }
    }
}
