import React from "react";
import { Album, ListMusic, Mic2, Radio, Sparkles } from "lucide-react";
import { Link } from "react-router-dom";
import { usePlayerStore } from "../store/usePlayerStore.js";

const library = [
  ["Listen Now", "/", Sparkles],
  ["Browse", "/", Album],
  ["Search", "/search", Radio],
  ["Songs", "/", ListMusic],
  ["Admin Music", "/admin/music", Mic2],
];

export function LibraryNav() {
  const playlists = usePlayerStore((s) => s.playlists);
  const profile = usePlayerStore((s) => s.profile);

  return (
    <nav className="grid gap-5 text-sm">
      <div className="grid gap-2">
        <h2 className="text-xs font-semibold uppercase text-muted">Discover</h2>
        {library.filter(([label]) => label !== "Admin Music" || profile?.role === "ADMIN").map(([label, to, Icon]) => (
          <Link key={label} to={to} className="flex items-center gap-2 rounded-md px-2 py-1.5 text-foreground">
            <Icon className="h-4 w-4" /> {label}
          </Link>
        ))}
      </div>
      <div className="grid gap-2">
        <h2 className="text-xs font-semibold uppercase text-muted">Playlists</h2>
        {playlists.slice(0, 8).map((playlist) => (
          <Link key={playlist.id} to={`/playlists/${playlist.id}`} className="truncate rounded-md px-2 py-1.5 text-muted">
            {playlist.name}
          </Link>
        ))}
      </div>
    </nav>
  );
}
