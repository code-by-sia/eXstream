import http from "node:http";

const profile = { username: "test", profileName: "Test Listener", role: "ADMIN", avatar: "🎧", token: "mock-token" };

const users = [
  { username: "admin", role: "ADMIN", profileName: "Admin", email: "admin@exstream.local", avatar: "🎛️" },
  { username: "test", role: "USER", profileName: "Test Listener", email: "test@exstream.local", avatar: "🎧" },
];

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

// In-memory file store (path -> content), mimicking the folder-backed file
// service. Seeded with one cover so cover resolution can be exercised.
const sampleCover =
  "data:image/svg+xml;utf8," +
  encodeURIComponent(
    "<svg xmlns='http://www.w3.org/2000/svg' width='300' height='300'>" +
      "<rect width='300' height='300' fill='#1db954'/>" +
      "<text x='50%' y='55%' text-anchor='middle' font-size='120' fill='white'>♫</text></svg>"
  );
const files = new Map([["covers/sample", sampleCover]]);
playlists[0].tracks[0].coverUrl = "/file/covers/sample";

function json(res, body, status = 200) {
  res.writeHead(status, { "Content-Type": "application/json" });
  res.end(JSON.stringify(body));
}

function readBody(req) {
  return new Promise((resolve) => {
    let body = "";
    req.on("data", (chunk) => (body += chunk));
    req.on("end", () => resolve(body));
  });
}

http
  .createServer((req, res) => {
    const url = new URL(req.url, "http://localhost");
    if (req.method !== "GET") console.log(`${new Date().toISOString()} ${req.method} ${url.pathname}`);
    if (req.method === "POST" && (url.pathname === "/auth/login" || url.pathname === "/auth/register")) return json(res, profile);
    if (req.method === "POST" && url.pathname === "/auth/change-password") {
      return readBody(req).then((body) => {
        const { currentPassword } = JSON.parse(body || "{}");
        if (currentPassword === "WRONG") return json(res, "current password is incorrect", 401);
        json(res, { ok: true, message: "password changed" });
      });
    }
    if (url.pathname === "/auth/admin/users" && req.method === "GET") return json(res, { users });
    if (url.pathname === "/auth/admin/users" && req.method === "POST") {
      return readBody(req).then((body) => {
        const data = JSON.parse(body || "{}");
        if (users.some((u) => u.username === data.username)) return json(res, "user already exists", 409);
        const user = { username: data.username, role: data.role === "ADMIN" ? "ADMIN" : "USER", profileName: data.profileName, email: data.email, avatar: data.avatar };
        users.push(user);
        json(res, { username: user.username, role: user.role, profileName: user.profileName, email: user.email, avatar: user.avatar });
      });
    }
    if (req.method === "POST" && url.pathname === "/auth/admin/reset-password") {
      return readBody(req).then(() => json(res, { ok: true, message: "password reset" }));
    }
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
    if (req.method === "POST" && url.pathname === "/file") {
      req.resume();
      req.on("end", () => json(res, { url: `tone:${220 + Math.floor(Math.random() * 200)},330,392,494` }));
      return;
    }
    if (url.pathname.startsWith("/file/")) {
      const path = decodeURIComponent(url.pathname.slice("/file/".length));
      if (req.method === "GET") {
        if (!files.has(path)) return json(res, { error: "not found" }, 404);
        return json(res, { path, content: files.get(path) });
      }
      if (req.method === "POST" || req.method === "PUT") {
        readBody(req).then((body) => {
          if (req.method === "POST" && files.has(path)) return json(res, { error: "exists" }, 409);
          const data = body ? JSON.parse(body) : {};
          files.set(path, data.content || "");
          json(res, { ok: true, message: req.method === "POST" ? "created" : "updated" });
        });
        return;
      }
      if (req.method === "DELETE") { files.delete(path); return json(res, { ok: true, message: "deleted" }); }
    }
    const moveMatch = url.pathname.match(/^\/playlists\/([^/]+)\/tracks\/([^/]+)\/move$/);
    if (moveMatch && req.method === "POST") {
      const source = playlists.find((p) => p.id === moveMatch[1]);
      if (!source) return json(res, { error: "not found" }, 404);
      readBody(req).then((body) => {
        const target = playlists.find((p) => p.id === (JSON.parse(body || "{}").targetPlaylistId));
        if (!target) return json(res, { error: "target not found" }, 404);
        const index = source.tracks.findIndex((t) => t.id === moveMatch[2]);
        if (index < 0) return json(res, { error: "track not found" }, 404);
        const [track] = source.tracks.splice(index, 1);
        target.tracks.push(track);
        json(res, target);
      });
      return;
    }
    const trackMatch = url.pathname.match(/^\/playlists\/([^/]+)\/tracks(?:\/([^/]+))?$/);
    if (trackMatch) {
      const playlist = playlists.find((p) => p.id === trackMatch[1]);
      if (!playlist) return json(res, { error: "not found" }, 404);
      let body = "";
      req.on("data", (chunk) => (body += chunk));
      req.on("end", () => {
        const data = body ? JSON.parse(body) : {};
        if (req.method === "POST") playlist.tracks.push({ id: `t-${Date.now()}`, ...data });
        if (req.method === "PUT") {
          const track = playlist.tracks.find((t) => t.id === trackMatch[2]);
          if (track) Object.assign(track, data);
        }
        if (req.method === "DELETE") playlist.tracks = playlist.tracks.filter((t) => t.id !== trackMatch[2]);
        json(res, playlist);
      });
      return;
    }
    if (req.method === "DELETE" && url.pathname.startsWith("/playlists/")) {
      const index = playlists.findIndex((p) => url.pathname === `/playlists/${p.id}`);
      if (index < 0) return json(res, { error: "not found" }, 404);
      playlists.splice(index, 1);
      return json(res, { ok: true, message: "deleted" });
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
