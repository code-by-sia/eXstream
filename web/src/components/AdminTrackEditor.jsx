import React from "react";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";

export function AdminTrackEditor({ onCancel, onSave, track }) {
  function submit(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    onSave({
      ...track,
      artist: form.get("artist"),
      title: form.get("title"),
      url: form.get("url"),
    });
  }

  return (
    <form className="admin-editor" onSubmit={submit}>
      <Input name="title" defaultValue={track.title} placeholder="Title" required />
      <Input name="artist" defaultValue={track.artist} placeholder="Artist" />
      <Input name="url" defaultValue={track.url} placeholder="File URL" required />
      <div className="admin-editor-actions">
        <Button type="submit">Save</Button>
        <Button type="button" variant="outline" onClick={onCancel}>Cancel</Button>
      </div>
    </form>
  );
}
