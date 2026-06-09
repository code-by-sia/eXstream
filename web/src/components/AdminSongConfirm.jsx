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
    <form className="mt-4 grid gap-3 rounded-md border border-border bg-background p-3 text-sm" onSubmit={submit}>
      <div>
        <p className="font-medium">Create this song in the library?</p>
        <p className="text-xs text-muted">The file upload is complete. Review the detected metadata.</p>
      </div>
      {pending.coverUrl ? (
        <div className="flex items-center gap-3 rounded-md border border-border p-2">
          <img src={pending.coverUrl} alt="" className="size-16 rounded-md object-cover" />
          <div className="min-w-0">
            <p className="text-xs font-medium">Album art detected</p>
            <p className="truncate text-xs text-muted">It will be saved with this song.</p>
          </div>
        </div>
      ) : null}
      <div className="grid gap-2">
        <Input name="title" defaultValue={pending.title} placeholder="Title" required disabled={disabled} />
        <Input name="artist" defaultValue={pending.artist} placeholder="Artist" disabled={disabled} />
        <p className="text-xs text-muted">Playlist: {pending.playlistName}</p>
      </div>
      <div className="flex flex-wrap gap-2">
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
