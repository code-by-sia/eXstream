import React from "react";
import { Play } from "lucide-react";
import { CoverImage } from "./CoverImage.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";

export function TrackList({ tracks }) {
  const setNowPlaying = usePlayerStore((s) => s.setNowPlaying);

  if (!tracks.length) return <p className="text-sm text-muted">No songs found.</p>;
  return (
    <div className="grid overflow-hidden rounded-lg border border-border">
      {tracks.map((track) => (
        <div key={`${track.playlistId}-${track.id}`} className="grid grid-cols-[3rem_1fr_auto] items-center gap-3 border-b border-border bg-card p-3 last:border-b-0 hover:bg-accent">
          <CoverImage track={track} className="size-12" />
          <div className="min-w-0">
            <p className="truncate text-sm font-semibold">{track.title}</p>
            <p className="truncate text-xs text-muted">{track.artist || "Unknown artist"} · {track.playlistName || "Library"}</p>
          </div>
          <Button type="button" variant="ghost" onClick={() => setNowPlaying(track)} aria-label={`Play ${track.title}`}>
            <Play className="h-4 w-4" />
          </Button>
        </div>
      ))}
    </div>
  );
}
