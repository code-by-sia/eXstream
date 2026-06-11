import React from "react";
import { Link } from "react-router-dom";
import { CoverImage } from "./CoverImage.jsx";

export function PlaylistGrid({ playlists }) {
  if (!playlists.length) return <p className="playlist-empty">No playlists yet.</p>;
  return (
    <div className="playlist-grid">
      {playlists.map((playlist) => (
        <Link key={playlist.id} to={`/playlists/${playlist.id}`} className="playlist-card">
          <CoverImage track={playlist.coverTrack} className="playlist-cover" />
          <div className="playlist-copy">
            <p className="playlist-title">{playlist.name}</p>
            <p className="playlist-subtitle">{playlist.subtitle}</p>
          </div>
        </Link>
      ))}
    </div>
  );
}
