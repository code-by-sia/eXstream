// Test blocks for the file service. Gathered and run via the root file-test.xi
// module (`xi test file-test.xi`).

test "accepts safe relative paths" (paths: FilePaths) {
    assert paths.isSafe("song.txt")
    assert paths.isSafe("albums/live/song.txt")
}

test "rejects unsafe paths" (paths: FilePaths) {
    assert not paths.isSafe("")
    assert not paths.isSafe("/tmp/song.txt")
    assert not paths.isSafe("../song.txt")
    assert not paths.isSafe("albums/")
    assert not paths.isSafe("albums\\song.txt")
}
