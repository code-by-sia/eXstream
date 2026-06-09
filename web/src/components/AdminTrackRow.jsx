import React from "react";
import { Button } from "./ui/button.jsx";
import { AdminTrackEditor } from "./AdminTrackEditor.jsx";
import { CoverImage } from "./CoverImage.jsx";

export function AdminTrackRow({ editing, onDelete, onEdit, onSave, track }) {
  if (editing) {
    return (
      <AdminTrackEditor
        track={track}
        onCancel={() => onEdit(undefined)}
        onSave={onSave}
      />
    );
  }

  return (
    <div className="grid gap-3 rounded-md border border-border bg-background p-3 sm:grid-cols-[3.5rem_1fr_auto]">
      <CoverImage track={track} className="size-14" />
      <div className="min-w-0">
        <p className="truncate text-sm font-medium">{track.title}</p>
        <p className="truncate text-xs text-muted">{track.artist || "Unknown artist"} · {track.playlistName}</p>
        <p className="truncate text-xs text-muted">{track.url}</p>
      </div>
      <div className="flex items-center gap-2">
        <Button type="button" variant="outline" onClick={() => onEdit(track.manageKey)}>Edit</Button>
        <Button type="button" variant="outline" onClick={() => onDelete(track)}>Delete</Button>
      </div>
    </div>
  );
}
