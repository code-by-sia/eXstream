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
    let content = "Favorites\nDaily\nsia\ntrack1|Song|Artist|http://audio|sia"
    let rendered = playlistJson("pl1", content)

    assert text.contains(rendered, "\"name\":\"Favorites\"")
    assert text.contains(rendered, "\"title\":\"Song\"")
}

module App {}
