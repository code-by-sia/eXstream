import React from "react";
import { useNavigate } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card.jsx";
import { Input } from "./ui/input.jsx";

export function PlaylistCreator({ refresh }) {
  const token = usePlayerStore((s) => s.token);
  const setSelected = usePlayerStore((s) => s.setSelected);
  const navigate = useNavigate();

  async function submit(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const playlist = await request("/playlists", {
      token,
      method: "POST",
      body: JSON.stringify(Object.fromEntries(form)),
    });
    setSelected(playlist);
    event.currentTarget.reset();
    await refresh();
    navigate(`/playlists/${playlist.id}`);
  }

  return (
    <Card>
      <CardHeader><CardTitle className="playlist-creator-title">New Playlist</CardTitle></CardHeader>
      <CardContent>
        <form className="playlist-creator-form" onSubmit={(event) => submit(event).catch(alert)}>
          <Input name="name" placeholder="Name" required />
          <Input name="description" placeholder="Description" />
          <Button type="submit" disabled={!token}>Create</Button>
        </form>
      </CardContent>
    </Card>
  );
}
