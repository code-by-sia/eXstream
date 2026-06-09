import React from "react";
import { PageSection } from "../components/PageSection.jsx";
import { TrackGrid } from "../components/TrackGrid.jsx";
import { allTracks } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { LibraryPageFrame } from "./LibraryPageFrame.jsx";

export function HomePage({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);
  const tracks = allTracks(playlists);

  return (
    <LibraryPageFrame refresh={refresh}>
      <PageSection title="Recently Added" subtitle="Fresh tracks from every playlist.">
        <TrackGrid tracks={tracks.slice(0, 6)} />
      </PageSection>
      <PageSection title="Made for You" subtitle="A compact mix pulled from your library.">
        <TrackGrid tracks={tracks.slice(0, 10)} compact />
      </PageSection>
    </LibraryPageFrame>
  );
}
