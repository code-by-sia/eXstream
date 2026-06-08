import React from "react";
import { Album, CirclePlay, Grid2X2, ListMusic, Mic2, Music, Radio, UserRound } from "lucide-react";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { SidebarSection } from "./SidebarSection.jsx";

const discover = [
  { label: "Listen Now", to: "/", icon: CirclePlay },
  { label: "Browse", to: "/", icon: Grid2X2 },
  { label: "Radio", to: "/search", icon: Radio },
];

const library = [
  { label: "Playlists", to: "/", icon: ListMusic },
  { label: "Songs", to: "/", icon: Music },
  { label: "Made for You", to: "/", icon: UserRound },
  { label: "Artists", to: "/search", icon: Mic2 },
  { label: "Albums", to: "/", icon: Album },
];

export function LibraryNav() {
  const playlists = usePlayerStore((s) => s.playlists);
  const profile = usePlayerStore((s) => s.profile);
  const admin = profile?.role === "ADMIN" ? [{ label: "Add Music", to: "/admin/music", icon: Mic2 }] : [];
  const playlistItems = playlists.slice(0, 8).map((playlist) => ({ label: playlist.name, to: `/playlists/${playlist.id}`, icon: ListMusic }));

  return (
    <nav className="grid gap-7">
      <SidebarSection title="Discover" items={[...discover, ...admin]} />
      <SidebarSection title="Library" items={library} />
      <SidebarSection title="Playlists" items={playlistItems} />
    </nav>
  );
}
