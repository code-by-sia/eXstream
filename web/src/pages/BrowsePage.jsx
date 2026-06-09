import React from "react";
import { PageSection } from "../components/PageSection.jsx";
import { PlaylistGrid } from "../components/PlaylistGrid.jsx";
import { TrackGrid } from "../components/TrackGrid.jsx";
import { allTracks, playlistCards } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { LibraryPageFrame } from "./LibraryPageFrame.jsx";

export function BrowsePage({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);
  const tracks = allTracks(playlists);

  return (
    <LibraryPageFrame refresh={refresh}>
      <PageSection title="Featured Collections" subtitle="Open a playlist and start listening.">
        <PlaylistGrid playlists={playlistCards(playlists)} />
      </PageSection>
      <PageSection title="All Music" subtitle="Everything available in the catalog.">
        <TrackGrid tracks={tracks} compact />
      </PageSection>
    </LibraryPageFrame>
  );
}
