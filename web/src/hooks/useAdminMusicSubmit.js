import React from "react";
import { useNavigate } from "react-router-dom";
import { createLibrarySong, trackFromUpload } from "../api/admin-music.js";
import { uploadMusicFile } from "../api/files.js";
import { readMusicMetadata } from "../api/music-metadata.js";
import { usePlayerStore } from "../store/usePlayerStore.js";

export const idleUploadStatus = { phase: "idle", progress: 0, message: "" };

export function useAdminMusicSubmit(refresh) {
  const token = usePlayerStore((s) => s.token);
  const setSelected = usePlayerStore((s) => s.setSelected);
  const navigate = useNavigate();
  const formRef = React.useRef();
  const [lastLink, setLastLink] = React.useState("");
  const [pending, setPending] = React.useState();
  const [status, setStatus] = React.useState(idleUploadStatus);
  const busy = status.phase === "uploading" || status.phase === "metadata" || status.phase === "saving";
  const formDisabled = busy || Boolean(pending);
  const submitLabel = pending ? "Confirm below" : busy ? "Working..." : "Upload file";

  async function submit(event) {
    event.preventDefault();
    const formElement = event.currentTarget;
    const form = new FormData(formElement);
    const playlist = formElement.elements.playlistId;
    const file = form.get("file");

    if (!file?.size) {
      setStatus({ phase: "error", progress: 0, message: "Select an audio file first." });
      return;
    }

    try {
      formRef.current = formElement;
      setPending(undefined);
      setLastLink("");
      setStatus({ phase: "uploading", progress: 35, message: "Uploading file..." });
      const url = await uploadMusicFile(token, file);
      setStatus({ phase: "metadata", progress: 55, message: "Reading browser metadata..." });
      const metadata = await readMusicMetadata(file);
      setLastLink(url);
      setPending(trackFromUpload(form, playlist, url, metadata));
      setStatus({ phase: "uploaded", progress: 70, message: "File uploaded. Review the detected song details." });
    } catch (error) {
      setStatus({ phase: "error", progress: 100, message: error.message || "Upload failed." });
    }
  }

  async function confirmSong(track = pending) {
    if (!track) return;

    try {
      setStatus({ phase: "saving", progress: 85, message: "Creating song in library..." });
      const playlist = await createLibrarySong(token, track);
      setSelected(playlist);
      await refresh();
      formRef.current?.reset();
      setPending(undefined);
      setStatus({ phase: "done", progress: 100, message: "Song created. Showing it in the library." });
      navigate(`/playlists/${track.playlistId}`);
    } catch (error) {
      setStatus({ phase: "error", progress: 100, message: error.message || "Could not create song." });
    }
  }

  function cancelSong() {
    setPending(undefined);
    setLastLink("");
    setStatus(idleUploadStatus);
  }

  return { busy, cancelSong, confirmSong, formDisabled, lastLink, pending, status, submit, submitLabel };
}
