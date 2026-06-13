import "../business/playlists.xi"

test "guards playlist identifiers" {
    assert safeId("abc123")
    assert not safeId("")
    assert not safeId("../abc")
    assert not safeId("abc/def")
}

test "checks playlist access" {
    let playlist = Playlist { found: true, id: "pl1", name: "Favorites", description: "Daily", owner: "sia", tracks: empty List<Track> }

    assert canAccessPlaylist(playlist, "sia", "USER")
    assert canAccessPlaylist(playlist, "anyone", "ADMIN")
    assert not canAccessPlaylist(playlist, "other", "USER")
}

test "serializes playlists with tracks" {
    let tracks = empty List<Track>
    tracks.push(Track { id: "track1", title: "Song", artist: "Artist", url: "http://audio", addedBy: "sia", coverUrl: "data:image/png;base64,abc" })
    let playlist = Playlist { found: true, id: "pl1", name: "Favorites", description: "Daily", owner: "sia", tracks: tracks }
    let rendered = playlistJson(playlist)

    assert text.contains(rendered, "\"name\":\"Favorites\"")
    assert text.contains(rendered, "\"title\":\"Song\"")
    assert text.contains(rendered, "\"coverUrl\":\"data:image/png;base64,abc\"")
}

test "creates, updates, and deletes tracks through the repository" (repo: PlaylistRepository) {
    let id = repo.create("Manage", "Admin tools", "admin")
    assert id != ""

    let trackId = repo.addTrack(id, "Old title", "Old artist", "/file/old", "admin", "cover-old")
    assert trackId != ""

    assert repo.updateTrack(id, trackId, "New title", "New artist", "/file/new", "cover-new") == "updated"
    let updated = repo.get(id)
    assert updated.found
    assert updated.tracks.get(0).title == "New title"
    assert updated.tracks.get(0).url == "/file/new"

    assert repo.deleteTrack(id, trackId) == "deleted"
    assert repo.get(id).tracks.isEmpty()

    assert repo.remove(id)
    assert not repo.get(id).found
}

module App {}
