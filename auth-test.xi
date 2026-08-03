import "std/config.xi"

// Root test module for the auth service. Gathers the whole service AND its
// test/ folder by glob, then `xi test auth-test.xi` runs every gathered test
// block. (A test file under auth/test/ can't glob its siblings itself, because
// includes globs don't traverse up with `../`.)
module App {
    id = "auth-test"
    includes = ["auth/**", "common/**"]
    bind AppConfig -> readConfig("common/config.yaml")
    bind QueryProvider  -> SqliteQueryProvider as singleton
    bind DatabaseBinder -> SqliteQueryProvider as singleton
    bind MonitoringRegistry -> MonitorRegistry as singleton
}
