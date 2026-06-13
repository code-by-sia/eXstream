// Decides whether a caller may see or modify a playlist. Implemented by
// OwnerPlaylistAccess (owner-or-admin).
interface PlaylistAccess {
    predicate canAccess(playlist: Playlist, username: String, role: String)
}
