import React from "react";
import { Play } from "lucide-react";
import { CoverImage } from "./CoverImage.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function AlbumCard({ track }) {
  const setNowPlaying = usePlayerStore((s) => s.setNowPlaying);

  return (
    <button type="button" className="group grid rounded-lg p-3 text-left transition hover:bg-accent" onClick={() => setNowPlaying(track)}>
      <div className="grid gap-3">
        <div className="relative">
          <CoverImage track={track} className="aspect-square w-full shadow-lg" />
          <span className="absolute bottom-2 right-2 grid size-10 place-items-center rounded-full bg-primary text-white opacity-0 shadow-lg transition group-hover:opacity-100">
            <Play className="h-4 w-4 fill-current" />
          </span>
        </div>
        <div className="grid gap-1">
          <strong className="truncate text-sm">{track.title}</strong>
          <span className="truncate text-xs text-muted">{track.artist || "Unknown artist"}</span>
        </div>
      </div>
    </button>
  );
}
