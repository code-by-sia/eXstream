// Domain records for the playlist service. The `found` flag on Playlist is an
// in-memory sentinel for "no such row"; it is only ever true on records that
// reach the wire (res.send serializes them directly).
type Track = { id: String, title: String, artist: String, url: String, addedBy: String, coverUrl: String }
type Playlist = { found: Bool, id: String, name: String, description: String, owner: String, tracks: List<Track> }
type MusicHit = { id: String, playlistId: String, title: String, artist: String, url: String, addedBy: String, coverUrl: String }
// Outcome carried out of the PlaylistService use-cases (see playlist-service.xi).
// Kept here so its embedded Playlist value is defined in the same file.
type PlaylistResult = { status: String, playlist: Playlist }
