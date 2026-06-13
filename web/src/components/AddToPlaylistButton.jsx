import React from "react";
import { useState } from "react";
import { ArrowRightLeft, ListPlus, Plus } from "lucide-react";
import { addTrackToPlaylist, moveTrackToPlaylist } from "../api/admin-music.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Dialog } from "./ui/dialog.jsx";

export function AddToPlaylistButton({ track, refresh }) {
  const [open, setOpen] = useState(false);
  const [busyId, setBusyId] = useState("");
  const [message, setMessage] = useState("");
  const token = usePlayerStore((s) => s.token);
  const playlists = usePlayerStore((s) => s.playlists);

  const targets = playlists.filter((playlist) => playlist.id !== track.playlistId);
  const canMove = Boolean(track.playlistId);

  async function run(targetId, move) {
    setBusyId(targetId + (move ? ":move" : ":add"));
    setMessage("");
    try {
      if (move) await moveTrackToPlaylist(token, targetId, track);
      else await addTrackToPlaylist(token, targetId, track);
      await refresh?.();
      setOpen(false);
    } catch (failure) {
      setMessage(failure.message || "Could not update playlist");
    }
    setBusyId("");
  }

  return (
    <>
      <button
        type="button"
        className="track-action-button"
        aria-label={`Add ${track.title} to a playlist`}
        title="Add to playlist"
        onClick={(event) => { event.stopPropagation(); setOpen(true); }}
      >
        <ListPlus className="icon-xs" />
      </button>
      <Dialog open={open} onClose={() => setOpen(false)} title="Add to Playlist" description={`Put “${track.title}” into another playlist.`}>
        {targets.length === 0 ? (
          <p className="empty-text">No other playlists yet.</p>
        ) : (
          <ul className="playlist-picker">
            {targets.map((playlist) => (
              <li key={playlist.id} className="playlist-picker-row">
                <span className="playlist-picker-name">{playlist.name}</span>
                <span className="playlist-picker-actions">
                  <button type="button" className="ui-button ui-button-outline playlist-picker-button" disabled={Boolean(busyId)} onClick={() => run(playlist.id, false)}>
                    <Plus className="icon-xs" /> Add
                  </button>
                  {canMove ? (
                    <button type="button" className="ui-button ui-button-outline playlist-picker-button" disabled={Boolean(busyId)} onClick={() => run(playlist.id, true)}>
                      <ArrowRightLeft className="icon-xs" /> Move
                    </button>
                  ) : null}
                </span>
              </li>
            ))}
          </ul>
        )}
        {message ? <p className="upload-message-error">{message}</p> : null}
      </Dialog>
    </>
  );
}
