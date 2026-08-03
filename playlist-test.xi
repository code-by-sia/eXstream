import "std/config.xi"

// Root test module for the playlist service. Gathers the whole service AND its
// test/ folder by glob; `xi test playlist-test.xi` runs every gathered test.
module App {
    id = "playlist-test"
    includes = ["playlist/**", "common/**"]
    bind AppConfig -> readConfig("common/config.yaml")
    bind QueryProvider  -> SqliteQueryProvider as singleton
    bind DatabaseBinder -> SqliteQueryProvider as singleton
    bind MonitoringRegistry -> MonitorRegistry as singleton
}
