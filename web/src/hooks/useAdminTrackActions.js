import React from "react";
import { deleteLibrarySong, updateLibrarySong } from "../api/admin-music.js";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function useAdminTrackActions(refresh) {
  const token = usePlayerStore((s) => s.token);
  const setSelected = usePlayerStore((s) => s.setSelected);
  const [editing, setEditing] = React.useState();
  const [message, setMessage] = React.useState("");

  async function save(track) {
    try {
      const playlist = await updateLibrarySong(token, track);
      setSelected(playlist);
      await refresh();
      setEditing(undefined);
      setMessage("Song updated.");
    } catch (error) {
      setMessage(error.message || "Could not update song.");
    }
  }

  async function remove(track) {
    try {
      const playlist = await deleteLibrarySong(token, track);
      setSelected(playlist);
      await refresh();
      setMessage("Song deleted.");
    } catch (error) {
      setMessage(error.message || "Could not delete song.");
    }
  }

  return { editing, message, remove, save, setEditing };
}
