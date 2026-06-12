import React from "react";
import { useState } from "react";
import { PlusCircle } from "lucide-react";
import { useParams } from "react-router-dom";
import { useAdminMusicSubmit } from "../hooks/useAdminMusicSubmit.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { AdminMusicForm } from "./AdminMusicForm.jsx";
import { AdminSongConfirm } from "./AdminSongConfirm.jsx";
import { AdminUploadStatus } from "./AdminUploadStatus.jsx";
import { Button } from "./ui/button.jsx";
import { Dialog } from "./ui/dialog.jsx";

export function AddMusicDialog({ refresh }) {
  const [open, setOpen] = useState(false);
  const playlists = usePlayerStore((s) => s.playlists);
  const { playlistId } = useParams();
  const upload = useAdminMusicSubmit(refresh);

  function close() {
    upload.cancelSong();
    setOpen(false);
  }

  async function confirm(track) {
    if (await upload.confirmSong(track)) close();
  }

  return (
    <>
      <Button type="button" onClick={() => setOpen(true)}>
        <PlusCircle className="button-icon-gap" /> Add music
      </Button>
      <Dialog
        open={open}
        onClose={close}
        title="Add Music"
        description="Upload an audio file, review its metadata, and store it as a playlist track."
      >
        <AdminMusicForm
          defaultPlaylistId={playlistId}
          disabled={upload.formDisabled}
          label={upload.submitLabel}
          playlists={playlists}
          onSubmit={upload.submit}
        />
        <AdminUploadStatus status={upload.status} lastLink={upload.lastLink} />
        <AdminSongConfirm disabled={upload.busy} pending={upload.pending} onCancel={upload.cancelSong} onConfirm={confirm} />
      </Dialog>
    </>
  );
}
