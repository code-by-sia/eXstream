import React from "react";
import { useAdminMusicSubmit } from "../hooks/useAdminMusicSubmit.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card.jsx";
import { AdminMusicForm } from "./AdminMusicForm.jsx";
import { AdminMusicLibrary } from "./AdminMusicLibrary.jsx";
import { AdminSongConfirm } from "./AdminSongConfirm.jsx";
import { AdminUploadStatus } from "./AdminUploadStatus.jsx";
import { PageHero } from "./PageHero.jsx";

export function AdminMusicManager({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);
  const upload = useAdminMusicSubmit(refresh);
  const heroTrack = playlists.flatMap((playlist) => playlist.tracks)[0];

  return (
    <section className="min-h-0 overflow-y-auto p-4 md:p-6 lg:p-8">
      <div className="mx-auto grid max-w-7xl gap-8">
        <PageHero
          title="Music Admin"
          subtitle="Upload tracks, review metadata, and manage the library."
          track={heroTrack}
        />
        <Card className="bg-background/70">
          <CardHeader>
            <CardTitle>Add a track</CardTitle>
            <CardDescription>Audio is uploaded first, then stored as a playlist track.</CardDescription>
          </CardHeader>
          <CardContent>
            <AdminMusicForm disabled={upload.formDisabled} label={upload.submitLabel} playlists={playlists} onSubmit={upload.submit} />
            <AdminUploadStatus status={upload.status} lastLink={upload.lastLink} />
            <AdminSongConfirm disabled={upload.busy} pending={upload.pending} onCancel={upload.cancelSong} onConfirm={upload.confirmSong} />
          </CardContent>
        </Card>
        <AdminMusicLibrary playlists={playlists} refresh={refresh} />
      </div>
    </section>
  );
}
