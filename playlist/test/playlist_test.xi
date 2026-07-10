// Test blocks for the playlist service. Gathered and run via the root
// playlist-test.xi module (`xi test playlist-test.xi`).

test "guards playlist identifiers" (paths: PlaylistPaths) {
    assert paths.isSafeId("abc123")
    assert not paths.isSafeId("")
    assert not paths.isSafeId("../abc")
    assert not paths.isSafeId("abc/def")
}

test "checks playlist access" (access: PlaylistAccess) {
    let playlist = Playlist { found: true, id: "pl1", name: "Favorites", description: "Daily", owner: "sia", tracks: empty List<Track> }

    assert access.canAccess(playlist, "sia", "USER")
    assert access.canAccess(playlist, "anyone", "ADMIN")
    assert not access.canAccess(playlist, "other", "USER")
}

test "denies playlist access through the service" (service: PlaylistService) {
    let id = service.create("Mine", "", "sia").id
    assert id != ""
    assert service.view(id, "sia", "USER").status == "ok"
    assert service.view(id, "intruder", "USER").status == "denied"
    assert service.view("nope", "sia", "USER").status == "not-found"
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
