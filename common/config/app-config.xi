import "std/config.xi"

// Typed view over common/config.yaml. Each method name maps to a top-level key
// in the file; std/config deserializes by return type. Every service binds it
// with `bind AppConfig -> readConfig("common/config.yaml")` in its module App.
interface AppConfig {
    mapper authPort() -> Integer
    mapper playlistPort() -> Integer
    mapper filePort() -> Integer
    mapper dataDir() -> String
    mapper fileStorageDir() -> String
}
