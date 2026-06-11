import React from "react";
import { Play } from "lucide-react";
import { CoverImage } from "./CoverImage.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function AlbumCard({ track }) {
  const setNowPlaying = usePlayerStore((s) => s.setNowPlaying);

  return (
    <button type="button" className="album-card" onClick={() => setNowPlaying(track)}>
      <div className="album-card-inner">
        <div className="album-art-shell">
          <CoverImage track={track} className="album-cover" />
          <span className="album-play-button">
            <Play className="icon-sm icon-fill-current" />
          </span>
        </div>
        <div className="album-card-copy">
          <strong className="album-card-title">{track.title}</strong>
          <span className="album-card-subtitle">{track.artist || "Unknown artist"}</span>
        </div>
      </div>
    </button>
  );
}
