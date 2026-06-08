import React from "react";
import { Button } from "./ui/button.jsx";
import { CoverImage } from "./CoverImage.jsx";

export function AlbumCard({ track, onPlay }) {
  return (
    <Button type="button" variant="ghost" className="h-auto justify-start p-0 text-left" onClick={onPlay}>
      <article className="grid w-full gap-2">
        <CoverImage track={track} className="aspect-square" />
        <div className="grid gap-1">
          <strong className="truncate text-sm">{track.title}</strong>
          <span className="truncate text-xs text-muted">{track.artist || "Unknown artist"}</span>
        </div>
      </article>
    </Button>
  );
}
