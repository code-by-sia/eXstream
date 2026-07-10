// Application/use-case layer for playlists. Controllers depend on this seam —
// never on PlaylistRepository directly — so access-control policy and
// persistence orchestration live in one place behind the HTTP layer.
// Implemented by PlaylistManager.
//
// Single-playlist operations return a PlaylistResult (defined alongside Playlist
// in playlist-records.xi) whose `status` the caller maps to an HTTP response:
// "ok" | "not-found" | "denied" | "track-not-found" | "target-not-found" |
// "target-denied" | "failed".

interface PlaylistService {
    producer listFor(username: String, role: String) -> List<Playlist>
    producer search(query: String, username: String, role: String) -> List<Playlist>
    producer searchTracks(query: String, username: String, role: String) -> List<MusicHit>
    producer create(name: String, description: String, owner: String) -> Playlist
    producer view(id: String, username: String, role: String) -> PlaylistResult
    producer remove(id: String, username: String, role: String) -> PlaylistResult
    producer addTrack(id: String, title: String, artist: String, url: String, username: String, role: String, coverUrl: String) -> PlaylistResult
    producer updateTrack(id: String, trackId: String, title: String, artist: String, url: String, coverUrl: String, username: String, role: String) -> PlaylistResult
    producer deleteTrack(id: String, trackId: String, username: String, role: String) -> PlaylistResult
    producer moveTrack(sourceId: String, trackId: String, targetId: String, username: String, role: String) -> PlaylistResult
}
