import http from "node:http";

const profile = { username: "test", profileName: "Test Listener", role: "ADMIN", avatar: "🎧", token: "mock-token" };

const playlists = [
  {
    id: "pl-1",
    name: "Starter Favorites",
    description: "Seeded favorites to explore the player.",
    owner: "test",
    tracks: [
      { id: "seed-track-1", title: "Midnight Pulse", artist: "eXstream Studio", url: "tone:220,277,330,415" },
      { id: "seed-track-2", title: "Glass Harbor", artist: "eXstream Studio", url: "tone:330,392,494,587" },
      { id: "seed-track-3", title: "Solar Steps", artist: "eXstream Studio", url: "tone:262,330,392,523" },
    ],
  },
  {
    id: "pl-2",
    name: "Ambient Loops",
    description: "Slow ambient textures.",
    owner: "test",
    tracks: [
      { id: "seed-track-4", title: "Slow Orbit", artist: "Aurora Drift", url: "tone:196,247,294,349" },
      { id: "seed-track-5", title: "Clean Room", artist: "Aurora Drift", url: "tone:294,370,440,554" },
      { id: "seed-track-6", title: "Open Sky", artist: "Night Voltage", url: "tone:262,311,392,466" },
    ],
  },
  {
    id: "pl-3",
    name: "Focus Flow",
    description: "Instrumentals for deep work.",
    owner: "test",
    tracks: [
      { id: "seed-track-7", title: "Quiet Engine", artist: "Night Voltage", url: "tone:233,294,349,440" },
      { id: "seed-track-8", title: "Paper Cranes", artist: "Mira Lane", url: "tone:262,330,415,494" },
    ],
  },
];

function json(res, body, status = 200) {
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(JSON.stringify(body));
}

http
  .createServer((req, res) => {
    const url = new URL(req.url, "http://localhost");
    if (req.method === "POST" && (url.pathname === "/auth/login" || url.pathname === "/auth/register")) return json(res, profile);
    if (req.method === "POST" && url.pathname === "/playlists") {
      let body = "";
      req.on("data", (chunk) => (body += chunk));
      req.on("end", () => {
        const data = JSON.parse(body || "{}");
        const playlist = { id: `pl-${Date.now()}`, name: data.name || "Untitled", description: data.description || "", owner: "test", tracks: [] };
        playlists.push(playlist);
        json(res, playlist);
      });
      return;
    }
    if (url.pathname === "/auth/profile") return json(res, profile);
    if (url.pathname === "/playlists") return json(res, playlists);
    const byId = playlists.find((p) => url.pathname === `/playlists/${p.id}`);
    if (byId) return json(res, byId);
    if (url.pathname === "/music/search") {
      const q = (url.searchParams.get("q") || "").toLowerCase();
      const tracks = playlists
        .flatMap((p) => p.tracks.map((t) => ({ ...t, playlistId: p.id, playlistName: p.name })))
        .filter((t) => t.title.toLowerCase().includes(q) || (t.artist || "").toLowerCase().includes(q));
      return json(res, tracks);
    }
    json(res, { error: "not found" }, 404);
  })
  .listen(9099, () => console.log("mock api on 9099"));
