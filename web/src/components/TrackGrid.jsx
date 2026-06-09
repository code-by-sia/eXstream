import React from "react";
import { AlbumCard } from "./AlbumCard.jsx";

export function TrackGrid({ compact = false, tracks }) {
  const columns = compact ? "grid-cols-[repeat(auto-fill,minmax(140px,1fr))]" : "grid-cols-[repeat(auto-fill,minmax(180px,1fr))]";

  if (!tracks.length) return <p className="text-sm text-muted">No tracks yet.</p>;
  return (
    <div className={`grid ${columns} gap-5`}>
      {tracks.map((track) => <AlbumCard key={`${track.playlistId}-${track.id}`} track={track} />)}
    </div>
  );
}
