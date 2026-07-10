import "std/config.xi"

// Root test module for the playlist service. Gathers the whole service AND its
// test/ folder by glob; `xi test playlist-test.xi` runs every gathered test.
module App {
    id = "playlist-test"
    includes = ["playlist/**", "common/**", "vendor/sqlite.xi"]
    bind AppConfig -> readConfig("common/config.yaml")
}
