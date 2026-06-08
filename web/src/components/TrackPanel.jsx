import React from "react";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { Card } from "./ui/card.jsx";
import { Input } from "./ui/input.jsx";
import { AlbumCard } from "./AlbumCard.jsx";

export function TrackPanel({ refresh }) {
  const token = usePlayerStore((s) => s.token);
  const selected = usePlayerStore((s) => s.selected);
  const setSelected = usePlayerStore((s) => s.setSelected);
  const setNowPlaying = usePlayerStore((s) => s.setNowPlaying);

  async function submit(event) {
    event.preventDefault();
    if (!selected || selected.id === "search") return;
    const form = new FormData(event.currentTarget);
    const playlist = await request(`/playlists/${selected.id}/tracks`, {
      token,
      method: "POST",
      body: JSON.stringify(Object.fromEntries(form)),
    });
    setSelected(playlist);
    event.currentTarget.reset();
    await refresh();
  }

  return (
    <Card className="grid content-start gap-5">
      <div className="grid gap-1">
        <h2 className="text-lg font-semibold">{selected?.name || "Listen Now"}</h2>
        <p className="text-sm text-muted">Top picks from your library.</p>
      </div>
      <form className="grid grid-cols-[1fr_1fr_1.5fr_auto] gap-2 max-xl:grid-cols-1" onSubmit={(event) => submit(event).catch(alert)}>
        <Input name="title" placeholder="Title" required />
        <Input name="artist" placeholder="Artist" />
        <Input name="url" placeholder="Audio URL" required />
        <Button type="submit" disabled={!selected || selected.id === "search"}>Add</Button>
      </form>
      <div className="grid grid-cols-[repeat(auto-fill,minmax(150px,1fr))] gap-4">
        {(selected?.tracks || []).map((track) => (
          <AlbumCard key={track.id} track={track} onPlay={() => setNowPlaying(track)} />
        ))}
      </div>
    </Card>
  );
}
