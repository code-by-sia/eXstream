import React from "react";
import { PageSection } from "../components/PageSection.jsx";
import { PlaylistGrid } from "../components/PlaylistGrid.jsx";
import { playlistCards } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { LibraryPageFrame } from "./LibraryPageFrame.jsx";

export function PlaylistsPage({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);

  return (
    <LibraryPageFrame refresh={refresh}>
      <PageSection title="Your Playlists" subtitle="Every saved collection in one place.">
        <PlaylistGrid playlists={playlistCards(playlists)} />
      </PageSection>
    </LibraryPageFrame>
  );
}
