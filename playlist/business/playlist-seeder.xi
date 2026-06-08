import "std/fs.xi"
import "playlist-paths.xi"

consumer seedStarterPlaylists() {
    seedPlaylist(
        "starter-favorites",
        "Starter Favorites\nRoyalty-free generated music for eXstream\n",
        "test\n"
            + "seed-track-1|Midnight Pulse|eXstream Studio|tone:220,277,330,415|system\n"
            + "seed-track-2|Glass Harbor|eXstream Studio|tone:330,392,494,587|system\n"
            + "seed-track-3|Solar Steps|eXstream Studio|tone:262,330,392,523|system"
    )
    seedPlaylist(
        "ambient-loops",
        "Ambient Loops\nSoft generated loops for testing playback\n",
        "test\n"
            + "seed-track-4|Slow Orbit|eXstream Studio|tone:196,247,294,349|system\n"
            + "seed-track-5|Clean Room|eXstream Studio|tone:294,370,440,554|system\n"
            + "seed-track-6|Open Sky|eXstream Studio|tone:247,311,370,494|system"
    )
}

consumer seedPlaylist(id: String, header: String, tracks: String) {
    playlistRoot()
    let p = playlistPath(id)
    if fs.isFile(p) { return }
    fs.writeFile(p, header + tracks)
}
