import React from "react";
import { UserRound } from "lucide-react";
import { CoverImage } from "./CoverImage.jsx";
import { Badge } from "./ui/badge.jsx";

export function ArtistGrid({ artists }) {
  if (!artists.length) return <p className="artist-empty">No artists yet.</p>;
  return (
    <div className="artist-grid">
      {artists.map((artist) => (
        <article key={artist.id} className="artist-card">
          <div className="artist-art-shell">
            <CoverImage track={artist.tracks[0]} className="artist-cover" />
            <span className="artist-badge-icon">
              <UserRound className="icon-sm" />
            </span>
          </div>
          <div className="artist-copy">
            <p className="artist-name">{artist.name}</p>
            <Badge>{artist.tracks.length} songs</Badge>
          </div>
        </article>
      ))}
    </div>
  );
}
