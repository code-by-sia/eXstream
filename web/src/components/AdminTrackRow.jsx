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
    <div className="admin-track-row">
      <CoverImage track={track} className="cover-size-14" />
      <div className="admin-track-meta">
        <p className="admin-track-title">{track.title}</p>
        <p className="admin-track-subtitle">{track.artist || "Unknown artist"} · {track.playlistName}</p>
        <p className="admin-track-url">{track.url}</p>
      </div>
      <div className="admin-track-actions">
        <Button type="button" variant="outline" onClick={() => onEdit(track.manageKey)}>Edit</Button>
        <Button type="button" variant="outline" onClick={() => onDelete(track)}>Delete</Button>
      </div>
    </div>
  );
}
