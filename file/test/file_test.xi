import "../business/file-paths.xi"

test "accepts safe relative paths" {
    assert safePath("song.txt")
    assert safePath("albums/live/song.txt")
}

test "rejects unsafe paths" {
    assert not safePath("")
    assert not safePath("/tmp/song.txt")
    assert not safePath("../song.txt")
    assert not safePath("albums/")
    assert not safePath("albums\\song.txt")
}

module App {}
