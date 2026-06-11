import React from "react";
import { Play } from "lucide-react";
import { CoverImage } from "./CoverImage.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";

export function TrackList({ tracks }) {
  const setNowPlaying = usePlayerStore((s) => s.setNowPlaying);

  if (!tracks.length) return <p className="track-empty">No songs found.</p>;
  return (
    <div className="track-list">
      {tracks.map((track) => (
        <div key={`${track.playlistId}-${track.id}`} className="track-row">
          <CoverImage track={track} className="cover-size-12" />
          <div className="track-row-meta">
            <p className="track-row-title">{track.title}</p>
            <p className="track-row-subtitle">{track.artist || "Unknown artist"} · {track.playlistName || "Library"}</p>
          </div>
          <Button type="button" variant="ghost" onClick={() => setNowPlaying(track)} aria-label={`Play ${track.title}`}>
            <Play className="icon-sm" />
          </Button>
        </div>
      ))}
    </div>
  );
}
