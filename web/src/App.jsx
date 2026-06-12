import React from "react";
import { useEffect } from "react";
import { Navigate, Route, Routes } from "react-router-dom";
import { request } from "./api/client.js";
import { AppFrame } from "./components/AppFrame.jsx";
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
      <Route element={<RequireAuth><AppFrame refresh={refresh} /></RequireAuth>}>
        <Route path="/" element={<HomePage refresh={refresh} />} />
        <Route path="/browse" element={<BrowsePage refresh={refresh} />} />
        <Route path="/radio" element={<RadioPage refresh={refresh} />} />
        <Route path="/library/playlists" element={<PlaylistsPage refresh={refresh} />} />
        <Route path="/library/songs" element={<SongsPage refresh={refresh} />} />
        <Route path="/made-for-you" element={<MadeForYouPage refresh={refresh} />} />
        <Route path="/artists" element={<ArtistsPage refresh={refresh} />} />
        <Route path="/albums" element={<AlbumsPage refresh={refresh} />} />
        <Route path="/playlists/:playlistId" element={<PlaylistPage refresh={refresh} />} />
        <Route path="/search" element={<SearchPage refresh={refresh} />} />
      </Route>
      <Route path="*" element={<Navigate to={token ? "/" : "/login"} replace />} />
    </Routes>
  );
}

function RequireAuth({ children }) {
  const token = usePlayerStore((s) => s.token);
  return token ? children : <Navigate to="/login" replace />;
}
