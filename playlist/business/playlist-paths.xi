// Parses playlist and track identifiers out of request paths and validates
// them. Implemented by RequestPlaylistPaths.
interface PlaylistPaths {
    mapper playlistId(reqPath: String) -> String
    mapper trackId(reqPath: String) -> String
    predicate isSafeId(id: String)
}
