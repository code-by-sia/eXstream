import React from "react";
import { useEffect } from "react";
import { Navigate, Route, Routes } from "react-router-dom";
import { request } from "./api/client.js";
import { AdminMusicPage } from "./pages/AdminMusicPage.jsx";
import { LoginPage } from "./pages/LoginPage.jsx";
import { MusicLayout } from "./pages/MusicLayout.jsx";
import { usePlayerStore } from "./store/usePlayerStore.js";

export function App() {
  const token = usePlayerStore((s) => s.token);
  const setProfile = usePlayerStore((s) => s.setProfile);
  const setPlaylists = usePlayerStore((s) => s.setPlaylists);

  async function refresh() {
    if (!token) return;
    setProfile(await request("/auth/profile", { token }));
    setPlaylists(await request("/playlists", { token }));
  }

  useEffect(() => {
    refresh().catch(() => {});
  }, [token]);

  return (
    <Routes>
      <Route path="/login" element={token ? <Navigate to="/" replace /> : <LoginPage refresh={refresh} />} />
      <Route path="/" element={<RequireAuth><MusicLayout refresh={refresh} /></RequireAuth>} />
      <Route path="/playlists/:playlistId" element={<RequireAuth><MusicLayout refresh={refresh} /></RequireAuth>} />
      <Route path="/search" element={<RequireAuth><MusicLayout refresh={refresh} /></RequireAuth>} />
      <Route path="/admin/music" element={<RequireAuth><AdminMusicPage refresh={refresh} /></RequireAuth>} />
      <Route path="*" element={<Navigate to={token ? "/" : "/login"} replace />} />
    </Routes>
  );
}

function RequireAuth({ children }) {
  const token = usePlayerStore((s) => s.token);
  return token ? children : <Navigate to="/login" replace />;
}
