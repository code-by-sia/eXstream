// Domain records for the playlist service. The `found` flag on Playlist is an
// in-memory sentinel for "no such row"; it is never serialized (the presenter
// emits only id/name/description/owner/tracks).
type Track = { id: String, title: String, artist: String, url: String, addedBy: String, coverUrl: String }
type Playlist = { found: Bool, id: String, name: String, description: String, owner: String, tracks: List<Track> }
type MusicHit = { id: String, playlistId: String, title: String, artist: String, url: String, addedBy: String, coverUrl: String }

mapper missingPlaylist(id: String) -> Playlist {
    return Playlist { found: false, id: id, name: "", description: "", owner: "", tracks: empty List<Track> }
}

predicate canAccessPlaylist(playlist: Playlist, username: String, role: String) {
    if role == "ADMIN" { return true }
    return playlist.owner == username
}
