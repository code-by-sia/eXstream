import React from "react";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";
import { Select } from "./ui/select.jsx";

export function AdminMusicForm({ defaultPlaylistId, busy, playlists, onSubmit }) {
  return (
    <form className="admin-music-form" onSubmit={onSubmit}>
      <Select name="playlistId" defaultValue={defaultPlaylistId} required disabled={busy}>
        {playlists.map((playlist) => (
          <option key={playlist.id} value={playlist.id}>{playlist.name}</option>
        ))}
      </Select>
      <Input name="file" type="file" accept="audio/*,.mp3" multiple required disabled={busy} />
      <Button type="submit" disabled={busy}>
        {busy ? "Uploading…" : "Upload & create"}
      </Button>
    </form>
  );
}
