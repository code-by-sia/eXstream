import "../business/files.xi"
import "std/config.xi"

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

module App {
    bind AppConfig -> readConfig("common/config.yaml")
}
