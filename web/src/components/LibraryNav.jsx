import React from "react";
import { Album, CirclePlay, Grid2X2, ListMusic, Mic2, Music, Radio, UserRound } from "lucide-react";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { PlaylistCreator } from "./PlaylistCreator.jsx";
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

export function LibraryNav({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);
  const playlistItems = playlists.map((playlist) => ({ label: playlist.name, to: `/playlists/${playlist.id}`, icon: ListMusic }));

  return (
    <nav className="library-nav">
      <SidebarSection title="Discover" items={discover} />
      <SidebarSection title="Library" items={library} />
      <SidebarSection
        className="sidebar-playlists-group"
        title="Playlists"
        action={<PlaylistCreator refresh={refresh} />}
        items={playlistItems}
      />
    </nav>
  );
}
