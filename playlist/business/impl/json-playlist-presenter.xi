import "std/json.xi"

class JsonPlaylistPresenter implements PlaylistPresenter {
    mapper playlist(item: Playlist) -> String {
        return json.stringify(playlistNode(item))
    }

    mapper playlists(items: List<Playlist>) -> String {
        let arr = json.array()
        for item in items { arr = json.push(arr, playlistNode(item)) }
        return json.stringify(arr)
    }

    mapper musicHits(items: List<MusicHit>) -> String {
        let arr = json.array()
        for hit in items { arr = json.push(arr, musicHitNode(hit)) }
        return json.stringify(arr)
    }

    mapper playlistNode(item: Playlist) -> Json {
        let tracks = json.array()
        for track in item.tracks { tracks = json.push(tracks, trackNode(track)) }

        let obj = json.object()
        obj = json.set(obj, "id", json.str(item.id))
        obj = json.set(obj, "name", json.str(item.name))
        obj = json.set(obj, "description", json.str(item.description))
        obj = json.set(obj, "owner", json.str(item.owner))
        obj = json.set(obj, "tracks", tracks)
        return obj
    }

    mapper trackNode(track: Track) -> Json {
        let obj = json.object()
        obj = json.set(obj, "id", json.str(track.id))
        obj = json.set(obj, "title", json.str(track.title))
        obj = json.set(obj, "artist", json.str(track.artist))
        obj = json.set(obj, "url", json.str(track.url))
        obj = json.set(obj, "addedBy", json.str(track.addedBy))
        obj = json.set(obj, "coverUrl", json.str(track.coverUrl))
        return obj
    }

    mapper musicHitNode(music: MusicHit) -> Json {
        let obj = json.object()
        obj = json.set(obj, "id", json.str(music.id))
        obj = json.set(obj, "playlistId", json.str(music.playlistId))
        obj = json.set(obj, "title", json.str(music.title))
        obj = json.set(obj, "artist", json.str(music.artist))
        obj = json.set(obj, "url", json.str(music.url))
        obj = json.set(obj, "addedBy", json.str(music.addedBy))
        obj = json.set(obj, "coverUrl", json.str(music.coverUrl))
        return obj
    }
}
