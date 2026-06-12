import React from "react";
import { useState } from "react";
import { Trash2 } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { Dialog } from "./ui/dialog.jsx";

export function PlaylistDelete({ playlist, refresh }) {
  const [open, setOpen] = useState(false);
  const token = usePlayerStore((s) => s.token);
  const profile = usePlayerStore((s) => s.profile);
  const setSelected = usePlayerStore((s) => s.setSelected);
  const navigate = useNavigate();

  const canDelete = playlist && profile && (playlist.owner === profile.username || profile.role === "ADMIN");
  if (!canDelete) return null;

  async function remove() {
    await request(`/playlists/${playlist.id}`, { token, method: "DELETE" });
    setOpen(false);
    setSelected(undefined);
    await refresh();
    navigate("/library/playlists");
  }

  return (
    <>
      <Button type="button" variant="outline" className="playlist-delete-trigger" onClick={() => setOpen(true)}>
        <Trash2 className="button-icon-gap" /> Delete
      </Button>
      <Dialog
        open={open}
        onClose={() => setOpen(false)}
        title="Delete Playlist"
        description={`This permanently removes “${playlist.name}” and its ${playlist.tracks?.length || 0} tracks.`}
      >
        <div className="ui-dialog-actions">
          <Button type="button" variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
          <Button type="button" variant="danger" onClick={() => remove().catch(alert)}>Delete Playlist</Button>
        </div>
      </Dialog>
    </>
  );
}
