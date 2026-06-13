type SeedTrack = { title: String, artist: String, url: String }

// Seeds the demo library once, through the repository (no direct storage
// access). Idempotent: skips if the seed user already has playlists.
consumer seedStarterPlaylists(repo: PlaylistRepository) {
    if not repo.listForUser("test", "USER").isEmpty() { return }

    seedPlaylist(repo, "Starter Favorites", "Royalty-free generated music for eXstream", listOf(
        SeedTrack { title: "Midnight Pulse", artist: "eXstream Studio", url: "tone:220,277,330,415" },
        SeedTrack { title: "Glass Harbor", artist: "eXstream Studio", url: "tone:330,392,494,587" },
        SeedTrack { title: "Solar Steps", artist: "eXstream Studio", url: "tone:262,330,392,523" }
    ))
    seedPlaylist(repo, "Ambient Loops", "Soft generated loops for testing playback", listOf(
        SeedTrack { title: "Slow Orbit", artist: "eXstream Studio", url: "tone:196,247,294,349" },
        SeedTrack { title: "Clean Room", artist: "eXstream Studio", url: "tone:294,370,440,554" },
        SeedTrack { title: "Open Sky", artist: "eXstream Studio", url: "tone:247,311,370,494" }
    ))
}

consumer seedPlaylist(repo: PlaylistRepository, name: String, description: String, tracks: List<SeedTrack>) {
    let id = repo.create(name, description, "test")
    if id == "" { return }
    for track in tracks {
        repo.addTrack(id, track.title, track.artist, track.url, "system", "")
    }
}
