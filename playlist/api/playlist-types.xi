type PlaylistWrite = { name: String, description: String }
type TrackWrite = { title: String, artist: String, url: String, coverUrl: String }
type TrackMove = { targetPlaylistId: String }
type PlaylistMessage = { ok: Bool, message: String }
