import React from "react";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Card } from "./ui/card.jsx";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";

export function AdminMusicManager({ refresh }) {
  const token = usePlayerStore((s) => s.token);
  const playlists = usePlayerStore((s) => s.playlists);

  async function submit(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const playlistId = form.get("playlistId");
    await request(`/playlists/${playlistId}/tracks`, {
      token,
      method: "POST",
      body: JSON.stringify(Object.fromEntries(form)),
    });
    event.currentTarget.reset();
    await refresh();
  }

  return (
    <section className="grid content-start gap-5 p-6">
      <div>
        <h1 className="text-2xl font-bold">Manage Music</h1>
        <p className="text-sm text-muted">Add tracks to any playlist.</p>
      </div>
      <Card>
        <form className="grid gap-3" onSubmit={(event) => submit(event).catch(alert)}>
          <select name="playlistId" className="min-h-10 rounded-md border border-border px-3 text-sm" required>
            {playlists.map((playlist) => <option key={playlist.id} value={playlist.id}>{playlist.name}</option>)}
          </select>
          <Input name="title" placeholder="Title" required />
          <Input name="artist" placeholder="Artist" />
          <Input name="url" placeholder="Audio URL" required />
          <Button type="submit">Add Track</Button>
        </form>
      </Card>
    </section>
  );
}
