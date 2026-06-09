import React from "react";
import { PlusCircle, RefreshCw, Search } from "lucide-react";
import { useLocation, useNavigate } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
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
    <div className="grid gap-3 md:grid-cols-[minmax(220px,420px)_auto]">
      <form className="relative" onSubmit={(event) => search(event).catch(() => {})}>
        <Search className="pointer-events-none absolute left-3 top-3 h-4 w-4 text-muted" />
        <Input name="q" defaultValue={current} className="pl-9" placeholder="Search music, artists, playlists" />
      </form>
      <div className="flex flex-wrap gap-2">
        <Button type="button" variant="outline" onClick={() => refresh().catch(alert)} aria-label="Refresh">
          <RefreshCw className="h-4 w-4" />
        </Button>
        {profile?.role === "ADMIN" ? (
          <Button type="button" onClick={() => navigate("/admin/music")}>
            <PlusCircle className="mr-2 h-4 w-4" /> Add music
          </Button>
        ) : null}
      </div>
    </div>
  );
}
