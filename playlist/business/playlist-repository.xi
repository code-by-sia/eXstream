// The persistence boundary for playlists. API handlers depend on this
// interface only — no SQL or storage details leak past it. The SQLite-backed
// implementor is SqlitePlaylistRepository; swap it by binding another in
// `module App`.
interface PlaylistRepository {
    producer get(id: String) -> Playlist
    producer listForUser(username: String, role: String) -> List<Playlist>
    producer searchPlaylists(query: String, username: String, role: String) -> List<Playlist>
    producer searchTracks(query: String, username: String, role: String) -> List<MusicHit>
    producer create(name: String, description: String, owner: String) -> String
    producer remove(id: String) -> Bool
    producer addTrack(id: String, title: String, artist: String, url: String, addedBy: String, coverUrl: String) -> String
    producer updateTrack(id: String, trackId: String, title: String, artist: String, url: String, coverUrl: String) -> String
    producer deleteTrack(id: String, trackId: String) -> String
    producer moveTrack(id: String, trackId: String, targetId: String) -> String
}
