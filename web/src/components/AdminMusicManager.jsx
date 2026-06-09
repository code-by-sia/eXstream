import React from "react";
import { useAdminMusicSubmit } from "../hooks/useAdminMusicSubmit.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card.jsx";
import { AdminMusicForm } from "./AdminMusicForm.jsx";
import { AdminUploadStatus } from "./AdminUploadStatus.jsx";

export function AdminMusicManager({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);
  const upload = useAdminMusicSubmit(refresh);

  return (
    <section className="grid content-start gap-5 p-6">
      <div>
        <h1 className="text-2xl font-bold">Manage Music</h1>
        <p className="text-sm text-muted">Upload tracks to the file service.</p>
      </div>
      <Card>
        <CardHeader>
          <CardTitle>Add a track</CardTitle>
          <CardDescription>Audio is uploaded first, then stored as a playlist track.</CardDescription>
        </CardHeader>
        <CardContent>
          <AdminMusicForm disabled={upload.busy} playlists={playlists} onSubmit={upload.submit} />
          <AdminUploadStatus status={upload.status} lastLink={upload.lastLink} />
        </CardContent>
      </Card>
    </section>
  );
}
