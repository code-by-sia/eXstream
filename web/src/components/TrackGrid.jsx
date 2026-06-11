import React from "react";
import { AlbumCard } from "./AlbumCard.jsx";

export function TrackGrid({ compact = false, tracks }) {
  if (!tracks.length) return <p className="track-empty">No tracks yet.</p>;
  return (
    <div className={compact ? "track-grid track-grid-compact" : "track-grid"}>
      {tracks.map((track) => <AlbumCard key={`${track.playlistId}-${track.id}`} track={track} />)}
    </div>
  );
}
