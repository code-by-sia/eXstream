import React from "react";
import { Link } from "react-router-dom";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";

export function PlaylistList() {
  const playlists = usePlayerStore((s) => s.playlists);
  const selected = usePlayerStore((s) => s.selected);

  return (
    <div className="min-w-0">
      <h2 className="text-base font-semibold">Playlists</h2>
      <div className="mt-3 grid gap-3">
        {playlists.map((playlist) => (
          <Button
            asChild
            key={playlist.id}
            variant="outline"
            className={selected?.id === playlist.id ? "border-focus" : ""}
          >
            <Link to={`/playlists/${playlist.id}`} className="grid w-full justify-items-start">
              <strong>{playlist.name}</strong>
              <span className="text-xs text-muted">{playlist.tracks.length} tracks · {playlist.owner}</span>
            </Link>
          </Button>
        ))}
      </div>
    </div>
  );
}
