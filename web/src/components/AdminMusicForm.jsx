import React from "react";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";
import { Select } from "./ui/select.jsx";

export function AdminMusicForm({ disabled, label, playlists, onSubmit }) {
  return (
    <form className="admin-music-form" onSubmit={onSubmit}>
      <Select name="playlistId" required disabled={disabled}>
        {playlists.map((playlist) => (
          <option key={playlist.id} value={playlist.id}>{playlist.name}</option>
        ))}
      </Select>
      <Input name="file" type="file" accept="audio/*" required disabled={disabled} />
      <Button type="submit" disabled={disabled}>
        {label}
      </Button>
    </form>
  );
}
