import React from "react";
import { CoverImage } from "./CoverImage.jsx";
import { Card, CardContent } from "./ui/card.jsx";

export function AlbumCard({ track, onPlay }) {
  return (
    <button type="button" className="group grid text-left" onClick={onPlay}>
      <Card className="border-transparent bg-transparent shadow-none transition group-hover:bg-accent">
        <CardContent className="grid gap-2 p-0">
        <CoverImage track={track} className="aspect-square" />
        <div className="grid gap-1">
          <strong className="truncate text-sm">{track.title}</strong>
          <span className="truncate text-xs text-muted">{track.artist || "Unknown artist"}</span>
        </div>
        </CardContent>
      </Card>
    </button>
  );
}
