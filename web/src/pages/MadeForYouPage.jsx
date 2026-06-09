import React from "react";
import { PageSection } from "../components/PageSection.jsx";
import { TrackGrid } from "../components/TrackGrid.jsx";
import { allTracks } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { LibraryPageFrame } from "./LibraryPageFrame.jsx";

export function MadeForYouPage({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);
  const tracks = allTracks(playlists);

  return (
    <LibraryPageFrame refresh={refresh}>
      <PageSection title="Daily Mix" subtitle="Familiar favorites and recent additions.">
        <TrackGrid tracks={tracks.slice(0, 12)} />
      </PageSection>
      <PageSection title="Deep Cuts" subtitle="More from the back half of your library.">
        <TrackGrid tracks={tracks.slice(4, 16)} compact />
      </PageSection>
    </LibraryPageFrame>
  );
}
