import React from "react";
import { useNavigate } from "react-router-dom";
import { createLibrarySong } from "../api/admin-music.js";
import { uploadCoverArt, uploadMusicFile } from "../api/files.js";
import { readMusicMetadata } from "../api/music-metadata.js";
import { usePlayerStore } from "../store/usePlayerStore.js";

// Batch upload: for each selected mp3, upload the audio, read ID3 metadata,
// cache the embedded album art via the file service, and create the song in
// the chosen playlist. Reports per-file progress.
export function useAdminMusicSubmit(refresh) {
  const token = usePlayerStore((s) => s.token);
  const setSelected = usePlayerStore((s) => s.setSelected);
  const navigate = useNavigate();
  const formRef = React.useRef();
  const [items, setItems] = React.useState([]);
  const [busy, setBusy] = React.useState(false);
  const [error, setError] = React.useState("");

  function patch(index, fields) {
    setItems((current) => current.map((item, i) => (i === index ? { ...item, ...fields } : item)));
  }

  async function submit(event) {
    event.preventDefault();
    const formElement = event.currentTarget;
    const form = new FormData(formElement);
    const playlistId = form.get("playlistId");
    const files = Array.from(formElement.elements.file.files || []);

    if (!files.length) {
      setError("Select at least one audio file.");
      return;
    }

    formRef.current = formElement;
    setError("");
    setBusy(true);
    setItems(files.map((file) => ({ name: file.name, status: "pending", message: "" })));

    let createdPlaylist;
    for (let index = 0; index < files.length; index += 1) {
      const file = files[index];
      try {
        patch(index, { status: "working", message: "Uploading audio…" });
        const url = await uploadMusicFile(token, file);

        patch(index, { message: "Reading tags…" });
        const metadata = await readMusicMetadata(file);
        const coverUrl = metadata.coverUrl ? await uploadCoverArt(token, metadata.coverUrl) : "";

        createdPlaylist = await createLibrarySong(token, {
          playlistId,
          title: metadata.title,
          artist: metadata.artist || "",
          url,
          coverUrl,
        });
        patch(index, { status: "done", title: metadata.title, hasArt: Boolean(coverUrl), message: coverUrl ? "Added · art cached" : "Added" });
      } catch (failure) {
        patch(index, { status: "error", message: failure.message || "Failed" });
      }
    }

    setBusy(false);
    if (createdPlaylist) {
      setSelected(createdPlaylist);
      await refresh();
    }
  }

  function reset() {
    formRef.current?.reset();
    setItems([]);
    setError("");
  }

  function done(playlistId) {
    reset();
    if (playlistId) navigate(`/playlists/${playlistId}`);
  }

  const finished = items.length > 0 && !busy;
  return { busy, items, error, finished, submit, reset, done };
}
