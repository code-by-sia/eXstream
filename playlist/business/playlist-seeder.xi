type SeedTrack = { title: String, artist: String, url: String }


interface DataSeeder {
    action seedPlaylists()
}

// Seeds the demo library once, through the repository (no direct storage
// access). Idempotent: skips if the seed user already has playlists.
class PlaylistDataSeeder implements DataSeeder {
    deps {
        repo:PlaylistRepository
    }

    action seedPlaylists(){
        if not repo.listForUser("test", "USER").isEmpty() { return }

        let favId = repo.create("Starter Favorites", "Royalty-free generated music for eXstream","test")
        repo.addTrack(favId,"Midnight Pulse","eXstream Studio","tone:220,277,330,415","system","")
        repo.addTrack(favId,"Glass Harbor","eXstream Studio","tone:330,392,494,587","system","")
        repo.addTrack(favId,"Solar Steps","eXstream Studio","tone:262,330,392,523","system","")

        let ambientId = repo.create("Ambient Loops", "Soft generated loops for testing playback","test")
        repo.addTrack(ambientId, "Slow Orbit", "eXstream Studio","tone:196,247,294,349","system","")
        repo.addTrack(ambientId, "Clean Room", "eXstream Studio","tone:294,370,440,554","system","")
        repo.addTrack(ambientId, "Open Sky", "eXstream Studio","tone:247,311,370,494","system","")
    }

}
