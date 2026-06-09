import React from "react";
import { useEffect } from "react";
import { Navigate, Route, Routes } from "react-router-dom";
import { request } from "./api/client.js";
import { AdminMusicPage } from "./pages/AdminMusicPage.jsx";
import { AlbumsPage } from "./pages/AlbumsPage.jsx";
import { ArtistsPage } from "./pages/ArtistsPage.jsx";
import { BrowsePage } from "./pages/BrowsePage.jsx";
import { HomePage } from "./pages/HomePage.jsx";
import { LoginPage } from "./pages/LoginPage.jsx";
import { MadeForYouPage } from "./pages/MadeForYouPage.jsx";
import { PlaylistPage } from "./pages/PlaylistPage.jsx";
import { PlaylistsPage } from "./pages/PlaylistsPage.jsx";
import { RadioPage } from "./pages/RadioPage.jsx";
import { SearchPage } from "./pages/SearchPage.jsx";
import { SongsPage } from "./pages/SongsPage.jsx";
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
      <Route path="/" element={<RequireAuth><HomePage refresh={refresh} /></RequireAuth>} />
      <Route path="/browse" element={<RequireAuth><BrowsePage refresh={refresh} /></RequireAuth>} />
      <Route path="/radio" element={<RequireAuth><RadioPage refresh={refresh} /></RequireAuth>} />
      <Route path="/library/playlists" element={<RequireAuth><PlaylistsPage refresh={refresh} /></RequireAuth>} />
      <Route path="/library/songs" element={<RequireAuth><SongsPage refresh={refresh} /></RequireAuth>} />
      <Route path="/made-for-you" element={<RequireAuth><MadeForYouPage refresh={refresh} /></RequireAuth>} />
      <Route path="/artists" element={<RequireAuth><ArtistsPage refresh={refresh} /></RequireAuth>} />
      <Route path="/albums" element={<RequireAuth><AlbumsPage refresh={refresh} /></RequireAuth>} />
      <Route path="/playlists/:playlistId" element={<RequireAuth><PlaylistPage refresh={refresh} /></RequireAuth>} />
      <Route path="/search" element={<RequireAuth><SearchPage refresh={refresh} /></RequireAuth>} />
      <Route path="/admin/music" element={<RequireAuth><AdminMusicPage refresh={refresh} /></RequireAuth>} />
      <Route path="*" element={<Navigate to={token ? "/" : "/login"} replace />} />
    </Routes>
  );
}

function RequireAuth({ children }) {
  const token = usePlayerStore((s) => s.token);
  return token ? children : <Navigate to="/login" replace />;
}
