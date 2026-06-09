import React from "react";
import { request } from "../api/client.js";
import { uploadMusicFile } from "../api/files.js";
import { usePlayerStore } from "../store/usePlayerStore.js";

export const idleUploadStatus = { phase: "idle", progress: 0, message: "" };

export function useAdminMusicSubmit(refresh) {
  const token = usePlayerStore((s) => s.token);
  const [lastLink, setLastLink] = React.useState("");
  const [status, setStatus] = React.useState(idleUploadStatus);
  const busy = status.phase === "uploading" || status.phase === "saving";

  async function submit(event) {
    event.preventDefault();
    const formElement = event.currentTarget;
    const form = new FormData(formElement);
    const file = form.get("file");

    if (!file?.size) {
      setStatus({ phase: "error", progress: 0, message: "Select an audio file first." });
      return;
    }

    try {
      setLastLink("");
      setStatus({ phase: "uploading", progress: 35, message: "Uploading file..." });
      const url = await uploadMusicFile(token, file);
      setLastLink(url);
      setStatus({ phase: "saving", progress: 75, message: "Adding track to playlist..." });
      await addTrack(token, form, url);
      formElement.reset();
      await refresh();
      setStatus({ phase: "done", progress: 100, message: "Track added to playlist." });
    } catch (error) {
      setStatus({ phase: "error", progress: 100, message: error.message || "Upload failed." });
    }
  }

  return { busy, lastLink, status, submit };
}

async function addTrack(token, form, url) {
  await request(`/playlists/${form.get("playlistId")}/tracks`, {
    token,
    method: "POST",
    body: JSON.stringify({ title: form.get("title"), artist: form.get("artist"), url }),
  });
}
