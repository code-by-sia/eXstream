import React from "react";
import { Button } from "./ui/button.jsx";

function initials(track) {
  return (track.title || "?").slice(0, 2).toUpperCase();
}

export function AlbumCard({ track, onPlay }) {
  return (
    <Button type="button" variant="ghost" className="h-auto justify-start p-0 text-left" onClick={onPlay}>
      <article className="grid w-full gap-2">
        <div className="grid aspect-square place-items-center rounded-md border border-border bg-slate-900 text-3xl font-bold text-white">
          {initials(track)}
        </div>
        <div className="grid gap-1">
          <strong className="truncate text-sm">{track.title}</strong>
          <span className="truncate text-xs text-muted">{track.artist || "Unknown artist"}</span>
        </div>
      </article>
    </Button>
  );
}
