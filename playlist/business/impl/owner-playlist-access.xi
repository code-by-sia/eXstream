class OwnerPlaylistAccess implements PlaylistAccess {
    deps {}

    predicate canAccess(playlist: Playlist, username: String, role: String) {
        if role == "ADMIN" { return true }
        return playlist.owner == username
    }
}
