import React from "react";
import { managedTracks } from "../api/admin-music.js";
import { useAdminTrackActions } from "../hooks/useAdminTrackActions.js";
import { AdminTrackRow } from "./AdminTrackRow.jsx";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card.jsx";

export function AdminMusicLibrary({ playlists, refresh }) {
  const actions = useAdminTrackActions(refresh);
  const tracks = managedTracks(playlists);

  return (
    <Card>
      <CardHeader>
        <CardTitle>Music library</CardTitle>
        <CardDescription>Edit or delete songs that are already in playlists.</CardDescription>
      </CardHeader>
      <CardContent className="grid gap-3">
        {tracks.length === 0 && <p className="text-sm text-muted">No songs yet.</p>}
        {tracks.map((track) => (
          <AdminTrackRow
            key={track.manageKey}
            track={track}
            editing={actions.editing === track.manageKey}
            onEdit={actions.setEditing}
            onSave={actions.save}
            onDelete={actions.remove}
          />
        ))}
        {actions.message && <p className="text-xs text-muted">{actions.message}</p>}
      </CardContent>
    </Card>
  );
}
