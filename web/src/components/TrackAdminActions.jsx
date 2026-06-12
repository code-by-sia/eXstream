import React from "react";
import { useState } from "react";
import { Pencil, Trash2 } from "lucide-react";
import { useAdminTrackActions } from "../hooks/useAdminTrackActions.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { AdminTrackEditor } from "./AdminTrackEditor.jsx";
import { Dialog } from "./ui/dialog.jsx";

export function TrackAdminActions({ track, refresh }) {
  const [editOpen, setEditOpen] = useState(false);
  const profile = usePlayerStore((s) => s.profile);
  const actions = useAdminTrackActions(refresh);

  if (profile?.role !== "ADMIN" || !track.playlistId) return null;

  async function save(updated) {
    await actions.save(updated);
    setEditOpen(false);
  }

  return (
    <span className="track-admin-actions">
      <button
        type="button"
        className="track-action-button"
        aria-label={`Edit ${track.title}`}
        title="Edit song"
        onClick={(event) => {
          event.stopPropagation();
          setEditOpen(true);
        }}
      >
        <Pencil className="icon-xs" />
      </button>
      <button
        type="button"
        className="track-action-button track-action-danger"
        aria-label={`Delete ${track.title}`}
        title="Delete song"
        onClick={(event) => {
          event.stopPropagation();
          actions.remove(track);
        }}
      >
        <Trash2 className="icon-xs" />
      </button>
      <Dialog open={editOpen} onClose={() => setEditOpen(false)} title="Edit Song" description={`In ${track.playlistName || "playlist"}`}>
        <AdminTrackEditor track={track} onSave={save} onCancel={() => setEditOpen(false)} />
        {actions.message ? <p className="admin-message">{actions.message}</p> : null}
      </Dialog>
    </span>
  );
}
