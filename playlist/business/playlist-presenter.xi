// Renders domain records as the JSON the web client expects. Kept separate
// from the repository so storage and wire format evolve independently.
// Implemented by JsonPlaylistPresenter.
interface PlaylistPresenter {
    mapper playlist(item: Playlist) -> String
    mapper playlists(items: List<Playlist>) -> String
    mapper musicHits(items: List<MusicHit>) -> String
}
