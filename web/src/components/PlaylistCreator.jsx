import React from "react";
import { useState } from "react";
import { Plus } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { Dialog } from "./ui/dialog.jsx";
import { Input } from "./ui/input.jsx";

export function PlaylistCreator({ refresh, variant = "icon" }) {
  const [open, setOpen] = useState(false);
  const token = usePlayerStore((s) => s.token);
  const setSelected = usePlayerStore((s) => s.setSelected);
  const navigate = useNavigate();

  async function submit(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const playlist = await request("/playlists", {
      token,
      method: "POST",
      body: JSON.stringify(Object.fromEntries(form)),
    });
    setSelected(playlist);
    setOpen(false);
    await refresh();
    navigate(`/playlists/${playlist.id}`);
  }

  return (
    <>
      {variant === "icon" ? (
        <button type="button" className="sidebar-section-action" onClick={() => setOpen(true)} aria-label="New playlist">
          <Plus className="icon-sm" />
        </button>
      ) : (
        <Button type="button" variant="outline" onClick={() => setOpen(true)}>
          <Plus className="button-icon-gap" /> New Playlist
        </Button>
      )}
      <Dialog
        open={open}
        onClose={() => setOpen(false)}
        title="New Playlist"
        description="Name your playlist and start collecting tracks."
      >
        <form className="playlist-creator-form" onSubmit={(event) => submit(event).catch(alert)}>
          <Input name="name" placeholder="Name" required autoFocus />
          <Input name="description" placeholder="Description (optional)" />
          <div className="ui-dialog-actions">
            <Button type="button" variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button type="submit" disabled={!token}>Create</Button>
          </div>
        </form>
      </Dialog>
    </>
  );
}
