import React from "react";
import { useState } from "react";
import { PlusCircle } from "lucide-react";
import { useParams } from "react-router-dom";
import { useAdminMusicSubmit } from "../hooks/useAdminMusicSubmit.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { AdminBatchStatus } from "./AdminBatchStatus.jsx";
import { AdminMusicForm } from "./AdminMusicForm.jsx";
import { Button } from "./ui/button.jsx";
import { Dialog } from "./ui/dialog.jsx";

export function AddMusicDialog({ refresh }) {
  const [open, setOpen] = useState(false);
  const playlists = usePlayerStore((s) => s.playlists);
  const { playlistId } = useParams();
  const upload = useAdminMusicSubmit(refresh);

  function close() {
    upload.reset();
    setOpen(false);
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
        description="Upload one or more MP3s. Title, artist, and album art are read from each file."
      >
        <AdminMusicForm
          defaultPlaylistId={playlistId}
          busy={upload.busy}
          playlists={playlists}
          onSubmit={upload.submit}
        />
        <AdminBatchStatus items={upload.items} error={upload.error} />
        {upload.finished ? (
          <div className="ui-dialog-actions">
            <Button type="button" variant="outline" onClick={upload.reset}>Upload more</Button>
            <Button type="button" onClick={() => { setOpen(false); upload.done(playlistId); }}>Done</Button>
          </div>
        ) : null}
      </Dialog>
    </>
  );
}
