import React from "react";
import { Album, CirclePlay, Disc3, Grid2X2, ListMusic, Mic2, Music, Radio, UserRound } from "lucide-react";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { SidebarSection } from "./SidebarSection.jsx";

const discover = [
  { label: "Listen Now", to: "/", icon: CirclePlay },
  { label: "Browse", to: "/browse", icon: Grid2X2 },
  { label: "Radio", to: "/radio", icon: Radio },
];

const library = [
  { label: "Playlists", to: "/library/playlists", icon: ListMusic },
  { label: "Songs", to: "/library/songs", icon: Music },
  { label: "Made for You", to: "/made-for-you", icon: UserRound },
  { label: "Artists", to: "/artists", icon: Mic2 },
  { label: "Albums", to: "/albums", icon: Album },
];

export function LibraryNav() {
  const playlists = usePlayerStore((s) => s.playlists);
  const profile = usePlayerStore((s) => s.profile);
  const admin = profile?.role === "ADMIN" ? [{ label: "Music Admin", to: "/admin/music", icon: Disc3 }] : [];
  const playlistItems = playlists.slice(0, 8).map((playlist) => ({ label: playlist.name, to: `/playlists/${playlist.id}`, icon: ListMusic }));

  return (
    <nav className="grid gap-7 max-lg:gap-4">
      <SidebarSection title="Discover" items={[...discover, ...admin]} />
      <SidebarSection title="Library" items={library} />
      <SidebarSection className="max-lg:hidden" title="Playlists" items={playlistItems} />
    </nav>
  );
}
