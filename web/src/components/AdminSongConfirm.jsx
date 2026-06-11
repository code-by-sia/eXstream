import React from "react";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";

export function AdminSongConfirm({ disabled, pending, onCancel, onConfirm }) {
  if (!pending) return null;

  function submit(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    onConfirm({ ...pending, artist: form.get("artist"), title: form.get("title") });
  }

  return (
    <form className="admin-confirm-form" onSubmit={submit}>
      <div>
        <p className="confirm-title">Create this song in the library?</p>
        <p className="confirm-subtitle">The file upload is complete. Review the detected metadata.</p>
      </div>
      {pending.coverUrl ? (
        <div className="confirm-art">
          <img src={pending.coverUrl} alt="" className="cover-image cover-size-16" />
          <div className="confirm-art-meta">
            <p className="confirm-art-title">Album art detected</p>
            <p className="confirm-subtitle">It will be saved with this song.</p>
          </div>
        </div>
      ) : null}
      <div className="confirm-fields">
        <Input name="title" defaultValue={pending.title} placeholder="Title" required disabled={disabled} />
        <Input name="artist" defaultValue={pending.artist} placeholder="Artist" disabled={disabled} />
        <p className="confirm-playlist">Playlist: {pending.playlistName}</p>
      </div>
      <div className="confirm-actions">
        <Button type="submit" disabled={disabled}>
          Create song in library
        </Button>
        <Button type="button" variant="outline" onClick={onCancel} disabled={disabled}>
          Cancel
        </Button>
      </div>
    </form>
  );
}
