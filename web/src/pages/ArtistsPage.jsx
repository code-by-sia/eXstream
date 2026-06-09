import React from "react";
import { ArtistGrid } from "../components/ArtistGrid.jsx";
import { PageSection } from "../components/PageSection.jsx";
import { artistGroups } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { LibraryPageFrame } from "./LibraryPageFrame.jsx";

export function ArtistsPage({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);

  return (
    <LibraryPageFrame refresh={refresh}>
      <PageSection title="Artists" subtitle="Grouped by performer across every playlist.">
        <ArtistGrid artists={artistGroups(playlists)} />
      </PageSection>
    </LibraryPageFrame>
  );
}
