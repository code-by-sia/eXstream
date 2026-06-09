import "../business/playlists.xi"

test "cleans fields for line storage" {
    assert cleanField(" chill | mix ") == "chill   mix"
    assert cleanField("line\nbreak") == "line break"
}

test "guards playlist identifiers" {
    assert safeId("abc123")
    assert not safeId("")
    assert not safeId("../abc")
    assert not safeId("abc/def")
}

test "checks playlist access" {
    let content = "Favorites\nDaily\nsia"

    assert canAccess(content, "sia", "USER")
    assert canAccess(content, "anyone", "ADMIN")
    assert not canAccess(content, "other", "USER")
}

test "serializes playlists with tracks" {
    let content = "Favorites\nDaily\nsia\ntrack1|Song|Artist|http://audio|sia|data:image/png;base64,abc"
    let rendered = playlistJson("pl1", content)

    assert text.contains(rendered, "\"name\":\"Favorites\"")
    assert text.contains(rendered, "\"title\":\"Song\"")
    assert text.contains(rendered, "\"coverUrl\":\"data:image/png;base64,abc\"")
}

test "updates and deletes playlist tracks" {
    let id = createPlaylist("Manage", "Admin tools", "admin")
    let trackId = addTrack(id, "Old title", "Old artist", "/file/old", "admin", "cover-old")

    assert updateTrack(id, trackId, "New title", "New artist", "/file/new", "cover-new") == "updated"
    let updated = playlistJson(id, readPlaylist(id))
    assert text.contains(updated, "\"title\":\"New title\"")
    assert text.contains(updated, "\"url\":\"/file/new\"")
    assert text.contains(updated, "\"coverUrl\":\"cover-new\"")

    assert deleteTrack(id, trackId) == "deleted"
    assert not text.contains(readPlaylist(id), "New title")
    deletePlaylist(id)
}

module App {}
