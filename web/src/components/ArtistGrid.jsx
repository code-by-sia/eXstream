import React from "react";
import { UserRound } from "lucide-react";
import { CoverImage } from "./CoverImage.jsx";
import { Badge } from "./ui/badge.jsx";

export function ArtistGrid({ artists }) {
  if (!artists.length) return <p className="text-sm text-muted">No artists yet.</p>;
  return (
    <div className="grid grid-cols-[repeat(auto-fill,minmax(180px,1fr))] gap-5">
      {artists.map((artist) => (
        <article key={artist.id} className="grid gap-3 rounded-lg bg-card p-4 transition hover:bg-accent">
          <div className="relative">
            <CoverImage track={artist.tracks[0]} className="aspect-square w-full rounded-full shadow-lg" />
            <span className="absolute bottom-2 right-2 rounded-full bg-foreground p-2 text-background">
              <UserRound className="h-4 w-4" />
            </span>
          </div>
          <div className="grid gap-2">
            <p className="truncate text-sm font-semibold">{artist.name}</p>
            <Badge>{artist.tracks.length} songs</Badge>
          </div>
        </article>
      ))}
    </div>
  );
}
