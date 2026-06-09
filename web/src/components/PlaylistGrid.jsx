import React from "react";
import { Link } from "react-router-dom";
import { CoverImage } from "./CoverImage.jsx";

export function PlaylistGrid({ playlists }) {
  if (!playlists.length) return <p className="text-sm text-muted">No playlists yet.</p>;
  return (
    <div className="grid grid-cols-[repeat(auto-fill,minmax(190px,1fr))] gap-5">
      {playlists.map((playlist) => (
        <Link key={playlist.id} to={`/playlists/${playlist.id}`} className="group grid gap-3 rounded-lg bg-card p-3 transition hover:bg-accent">
          <CoverImage track={playlist.coverTrack} className="aspect-square w-full shadow-lg" />
          <div className="min-w-0">
            <p className="truncate text-sm font-semibold">{playlist.name}</p>
            <p className="truncate text-xs text-muted">{playlist.subtitle}</p>
          </div>
        </Link>
      ))}
    </div>
  );
}
