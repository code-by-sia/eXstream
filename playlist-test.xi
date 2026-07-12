import "std/config.xi"

// Root test module for the playlist service. Gathers the whole service AND its
// test/ folder by glob; `xi test playlist-test.xi` runs every gathered test.
module App {
    id = "playlist-test"
    includes = ["playlist/**", "common/**"]
    dependencies = ["https://github.com/code-by-sia/xi-sqlite/archive/refs/tags/v0.2.0.tar.gz"]
    bind AppConfig -> readConfig("common/config.yaml")
    bind QueryProvider  -> SqliteQueryProvider as singleton
    bind DatabaseBinder -> SqliteQueryProvider as singleton
}
