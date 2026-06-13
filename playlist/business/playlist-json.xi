import "../../common/util/json-string.xi"

// Presentation layer: turns domain records into the JSON the web client
// expects. Kept separate from the repository so storage and wire format evolve
// independently.

mapper trackJson(track: Track) -> String {
    return "{"
        + "\"id\":" + jsonString(track.id) + ","
        + "\"title\":" + jsonString(track.title) + ","
        + "\"artist\":" + jsonString(track.artist) + ","
        + "\"url\":" + jsonString(track.url) + ","
        + "\"addedBy\":" + jsonString(track.addedBy) + ","
        + "\"coverUrl\":" + jsonString(track.coverUrl)
        + "}"
}

mapper playlistJson(playlist: Playlist) -> String {
    let tracks = "["
    let first = true
    for track in playlist.tracks {
        if not first { tracks = tracks + "," }
        first = false
        tracks = tracks + trackJson(track)
    }

    return "{"
        + "\"id\":" + jsonString(playlist.id) + ","
        + "\"name\":" + jsonString(playlist.name) + ","
        + "\"description\":" + jsonString(playlist.description) + ","
        + "\"owner\":" + jsonString(playlist.owner) + ","
        + "\"tracks\":" + tracks + "]"
        + "}"
}

mapper playlistsJson(playlists: List<Playlist>) -> String {
    let out = "["
    let first = true
    for playlist in playlists {
        if not first { out = out + "," }
        first = false
        out = out + playlistJson(playlist)
    }
    return out + "]"
}

mapper musicHitJson(music: MusicHit) -> String {
    return "{"
        + "\"id\":" + jsonString(music.id) + ","
        + "\"playlistId\":" + jsonString(music.playlistId) + ","
        + "\"title\":" + jsonString(music.title) + ","
        + "\"artist\":" + jsonString(music.artist) + ","
        + "\"url\":" + jsonString(music.url) + ","
        + "\"addedBy\":" + jsonString(music.addedBy) + ","
        + "\"coverUrl\":" + jsonString(music.coverUrl)
        + "}"
}

mapper musicHitsJson(hits: List<MusicHit>) -> String {
    let out = "["
    let first = true
    for music in hits {
        if not first { out = out + "," }
        first = false
        out = out + musicHitJson(music)
    }
    return out + "]"
}
