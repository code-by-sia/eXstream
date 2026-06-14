import React from "react";
import { useState } from "react";
import { ImagePlus, Loader } from "lucide-react";
import { uploadCoverArt } from "../api/files.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { CoverImage } from "./CoverImage.jsx";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";

function readAsDataUrl(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = () => reject(reader.error);
    reader.readAsDataURL(file);
  });
}

export function AdminTrackEditor({ onCancel, onSave, track }) {
  const token = usePlayerStore((s) => s.token);
  const [coverUrl, setCoverUrl] = useState(track.coverUrl || "");
  const [artBusy, setArtBusy] = useState(false);
  const [artError, setArtError] = useState("");

  async function pickArt(event) {
    const file = event.target.files?.[0];
    if (!file) return;
    setArtBusy(true);
    setArtError("");
    try {
      const url = await uploadCoverArt(token, await readAsDataUrl(file));
      setCoverUrl(url);
    } catch (failure) {
      setArtError(failure.message || "Could not upload image");
    }
    setArtBusy(false);
  }

  function submit(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    onSave({
      ...track,
      title: form.get("title"),
      artist: form.get("artist"),
      url: form.get("url"),
      coverUrl,
    });
  }

  return (
    <form className="admin-editor" onSubmit={submit}>
      <div className="admin-art-edit">
        <CoverImage track={{ ...track, coverUrl }} className="admin-art-preview" />
        <div className="admin-art-controls">
          <label className="admin-art-upload">
            {artBusy ? <Loader className="icon-sm animate-spin" /> : <ImagePlus className="icon-sm" />}
            <span>{artBusy ? "Uploading…" : "Change album art"}</span>
            <input type="file" accept="image/*" className="admin-art-input" onChange={pickArt} disabled={artBusy} />
          </label>
          {coverUrl ? (
            <button type="button" className="admin-art-remove" onClick={() => setCoverUrl("")}>Remove art</button>
          ) : null}
          {artError ? <p className="upload-message-error">{artError}</p> : null}
        </div>
      </div>
      <Input name="title" defaultValue={track.title} placeholder="Title" required />
      <Input name="artist" defaultValue={track.artist} placeholder="Artist" />
      <Input name="url" defaultValue={track.url} placeholder="Audio source URL" required />
      <div className="admin-editor-actions">
        <Button type="submit" disabled={artBusy}>Save</Button>
        <Button type="button" variant="outline" onClick={onCancel}>Cancel</Button>
      </div>
    </form>
  );
}
