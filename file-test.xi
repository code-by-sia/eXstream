import "std/config.xi"

// Root test module for the file service. Gathers the whole service AND its
// test/ folder by glob; `xi test file-test.xi` runs every gathered test.
module App {
    id = "file-test"
    includes = ["file/**", "common/config/**", "common/security/**", "common/monitoring/**"]
    bind AppConfig -> readConfig("common/config.yaml")
    bind MonitoringRegistry -> MonitorRegistry as singleton
}
