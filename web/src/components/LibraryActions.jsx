import React from "react";
import { RefreshCw, Search } from "lucide-react";
import { useLocation, useNavigate } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { AddMusicDialog } from "./AddMusicDialog.jsx";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";

export function LibraryActions({ refresh }) {
  const location = useLocation();
  const navigate = useNavigate();
  const token = usePlayerStore((s) => s.token);
  const profile = usePlayerStore((s) => s.profile);
  const setSelected = usePlayerStore((s) => s.setSelected);
  const current = new URLSearchParams(location.search).get("q") || "";

  async function search(event) {
    event.preventDefault();
    const q = event.currentTarget.elements.q.value.trim();
    const tracks = q ? await request(`/music/search?q=${encodeURIComponent(q)}`, { token }) : [];
    setSelected({ id: "search", name: "Search", tracks });
    navigate(q ? `/search?q=${encodeURIComponent(q)}` : "/search");
  }

  return (
    <div className="library-actions">
      <form className="library-search-form" onSubmit={(event) => search(event).catch(() => {})}>
        <Search className="library-search-icon" />
        <Input name="q" defaultValue={current} className="library-search-input" placeholder="Search music, artists, playlists" />
      </form>
      <div className="library-action-buttons">
        <Button type="button" variant="outline" onClick={() => refresh().catch(alert)} aria-label="Refresh">
          <RefreshCw className="icon-sm" />
        </Button>
        {profile?.role === "ADMIN" ? <AddMusicDialog refresh={refresh} /> : null}
      </div>
    </div>
  );
}
