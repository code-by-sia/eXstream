import React from "react";
import { Button } from "./ui/button.jsx";

export function AdminSongConfirm({ disabled, pending, onCancel, onConfirm }) {
  if (!pending) return null;

  return (
    <div className="mt-4 grid gap-3 rounded-md border border-border bg-background p-3 text-sm">
      <div>
        <p className="font-medium">Create this song in the library?</p>
        <p className="text-xs text-muted">The file upload is complete. Confirm to add it to the playlist.</p>
      </div>
      <div className="grid gap-1 text-xs text-muted">
        <span>Title: {pending.title}</span>
        <span>Artist: {pending.artist || "Unknown artist"}</span>
        <span>Playlist: {pending.playlistName}</span>
      </div>
      <div className="flex flex-wrap gap-2">
        <Button type="button" onClick={onConfirm} disabled={disabled}>
          Create song in library
        </Button>
        <Button type="button" variant="outline" onClick={onCancel} disabled={disabled}>
          Cancel
        </Button>
      </div>
    </div>
  );
}
