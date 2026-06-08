import React from "react";
import { PlusCircle, RotateCw } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";
import { MusicTabs } from "./MusicTabs.jsx";

export function Toolbar({ refresh }) {
  const token = usePlayerStore((s) => s.token);
  const profile = usePlayerStore((s) => s.profile);
  const selected = usePlayerStore((s) => s.selected);
  const setSelected = usePlayerStore((s) => s.setSelected);
  const navigate = useNavigate();

  async function search(event) {
    const q = encodeURIComponent(event.currentTarget.value);
    const tracks = q ? await request(`/music/search?q=${q}`, { token }) : [];
    setSelected({ id: "search", name: "Search", tracks });
    if (q) navigate(`/search?q=${q}`);
  }

  return (
    <header className="grid gap-5 bg-card p-5 lg:p-8">
      <div className="flex items-center justify-between gap-3">
        <MusicTabs />
        <div className="flex items-center gap-2">
          <Button type="button" variant="outline" onClick={() => refresh().catch(alert)} aria-label="Refresh">
            <RotateCw className="h-4 w-4" />
          </Button>
          {profile?.role === "ADMIN" && (
            <Button type="button" onClick={() => navigate("/admin/music")}>
              <PlusCircle className="mr-2 h-4 w-4" /> Add music
            </Button>
          )}
        </div>
      </div>
      <div className="grid gap-2 border-b border-border pb-5">
        <h1 className="text-3xl font-bold">{selected?.name || "Listen Now"}</h1>
        <p className="text-sm text-muted">Top picks for you. Updated daily.</p>
      </div>
      <Input placeholder="Search music, artists, playlists" onInput={(event) => search(event).catch(() => {})} />
    </header>
  );
}
