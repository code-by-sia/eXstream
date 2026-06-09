import React from "react";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";
import { Select } from "./ui/select.jsx";

export function AdminMusicForm({ disabled, playlists, onSubmit }) {
  return (
    <form className="grid gap-3" onSubmit={onSubmit}>
      <Select name="playlistId" required disabled={disabled}>
        {playlists.map((playlist) => (
          <option key={playlist.id} value={playlist.id}>{playlist.name}</option>
        ))}
      </Select>
      <Input name="title" placeholder="Title" required disabled={disabled} />
      <Input name="artist" placeholder="Artist" disabled={disabled} />
      <Input name="file" type="file" accept="audio/*" required disabled={disabled} />
      <Button type="submit" disabled={disabled}>
        {disabled ? "Adding..." : "Add Track"}
      </Button>
    </form>
  );
}
