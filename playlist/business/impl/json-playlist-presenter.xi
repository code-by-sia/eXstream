class JsonPlaylistPresenter implements PlaylistPresenter {
    deps { json: JsonText }

    mapper playlist(item: Playlist) -> String {
        let tracks = "["
        let first = true
        for track in item.tracks {
            if not first { tracks = tracks + "," }
            first = false
            tracks = tracks + trackJson(track)
        }

        return "{"
            + "\"id\":" + json.encode(item.id) + ","
            + "\"name\":" + json.encode(item.name) + ","
            + "\"description\":" + json.encode(item.description) + ","
            + "\"owner\":" + json.encode(item.owner) + ","
            + "\"tracks\":" + tracks + "]"
            + "}"
    }

    mapper playlists(items: List<Playlist>) -> String {
        let out = "["
        let first = true
        for item in items {
            if not first { out = out + "," }
            first = false
            out = out + playlist(item)
        }
        return out + "]"
    }

    mapper musicHits(items: List<MusicHit>) -> String {
        let out = "["
        let first = true
        for item in items {
            if not first { out = out + "," }
            first = false
            out = out + musicHitJson(item)
        }
        return out + "]"
    }

    mapper trackJson(track: Track) -> String {
        return "{"
            + "\"id\":" + json.encode(track.id) + ","
            + "\"title\":" + json.encode(track.title) + ","
            + "\"artist\":" + json.encode(track.artist) + ","
            + "\"url\":" + json.encode(track.url) + ","
            + "\"addedBy\":" + json.encode(track.addedBy) + ","
            + "\"coverUrl\":" + json.encode(track.coverUrl)
            + "}"
    }

    mapper musicHitJson(music: MusicHit) -> String {
        return "{"
            + "\"id\":" + json.encode(music.id) + ","
            + "\"playlistId\":" + json.encode(music.playlistId) + ","
            + "\"title\":" + json.encode(music.title) + ","
            + "\"artist\":" + json.encode(music.artist) + ","
            + "\"url\":" + json.encode(music.url) + ","
            + "\"addedBy\":" + json.encode(music.addedBy) + ","
            + "\"coverUrl\":" + json.encode(music.coverUrl)
            + "}"
    }
}
