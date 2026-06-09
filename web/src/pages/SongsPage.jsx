import React from "react";
import { PageSection } from "../components/PageSection.jsx";
import { TrackList } from "../components/TrackList.jsx";
import { allTracks } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { LibraryPageFrame } from "./LibraryPageFrame.jsx";

export function SongsPage({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);

  return (
    <LibraryPageFrame refresh={refresh}>
      <PageSection title="All Songs" subtitle="Every saved track, ready for playback.">
        <TrackList tracks={allTracks(playlists)} />
      </PageSection>
    </LibraryPageFrame>
  );
}
