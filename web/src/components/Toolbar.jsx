import React from "react";
import { useNavigate } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";
import { MusicTabs } from "./MusicTabs.jsx";

export function Toolbar({ refresh }) {
  const token = usePlayerStore((s) => s.token);
  const setSelected = usePlayerStore((s) => s.setSelected);
  const navigate = useNavigate();

  async function search(event) {
    const q = encodeURIComponent(event.currentTarget.value);
    const tracks = q ? await request(`/music/search?q=${q}`, { token }) : [];
    setSelected({ id: "search", name: "Search", tracks });
    if (q) navigate(`/search?q=${q}`);
  }

  return (
    <header className="grid gap-4 border-b border-border bg-white p-5">
      <div className="flex items-center justify-between gap-3">
        <MusicTabs />
        <Button type="button" variant="outline" onClick={() => refresh().catch(alert)}>Refresh</Button>
      </div>
      <Input placeholder="Search music" onInput={(event) => search(event).catch(() => {})} />
    </header>
  );
}
