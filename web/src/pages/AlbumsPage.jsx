import React from "react";
import { PageSection } from "../components/PageSection.jsx";
import { PlaylistGrid } from "../components/PlaylistGrid.jsx";
import { playlistCards } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { LibraryPageFrame } from "./LibraryPageFrame.jsx";

export function AlbumsPage({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);

  return (
    <LibraryPageFrame refresh={refresh}>
      <PageSection title="Albums" subtitle="Saved collections with artwork and track counts.">
        <PlaylistGrid playlists={playlistCards(playlists)} />
      </PageSection>
    </LibraryPageFrame>
  );
}
