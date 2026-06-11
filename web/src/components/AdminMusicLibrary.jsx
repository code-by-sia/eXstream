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
      <CardContent className="admin-library-content">
        {tracks.length === 0 && <p className="admin-empty">No songs yet.</p>}
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
        {actions.message && <p className="admin-message">{actions.message}</p>}
      </CardContent>
    </Card>
  );
}
