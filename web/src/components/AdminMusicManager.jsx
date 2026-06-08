import React from "react";
import { uploadMusicFile } from "../api/files.js";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card.jsx";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";
import { Select } from "./ui/select.jsx";

export function AdminMusicManager({ refresh }) {
  const token = usePlayerStore((s) => s.token);
  const playlists = usePlayerStore((s) => s.playlists);
  const [lastLink, setLastLink] = React.useState("");

  async function submit(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const playlistId = form.get("playlistId");
    const url = await uploadMusicFile(token, form.get("file"));

    await request(`/playlists/${playlistId}/tracks`, {
      token,
      method: "POST",
      body: JSON.stringify({ title: form.get("title"), artist: form.get("artist"), url }),
    });
    setLastLink(url);
    event.currentTarget.reset();
    await refresh();
  }

  return (
    <section className="grid content-start gap-5 p-6">
      <div>
        <h1 className="text-2xl font-bold">Manage Music</h1>
        <p className="text-sm text-muted">Upload tracks to the file service.</p>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Add a track</CardTitle>
          <CardDescription>Audio is uploaded first, then stored as a playlist track.</CardDescription>
        </CardHeader>
        <CardContent>
          <form className="grid gap-3" onSubmit={(event) => submit(event).catch(alert)}>
            <Select name="playlistId" required>
              {playlists.map((playlist) => <option key={playlist.id} value={playlist.id}>{playlist.name}</option>)}
            </Select>
            <Input name="title" placeholder="Title" required />
            <Input name="artist" placeholder="Artist" />
            <Input name="file" type="file" accept="audio/*" required />
            <Button type="submit">Add Track</Button>
          </form>
          {lastLink && <p className="mt-3 text-xs text-muted">Stored as {lastLink}</p>}
        </CardContent>
      </Card>
    </section>
  );
}
