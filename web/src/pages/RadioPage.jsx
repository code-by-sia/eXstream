import React from "react";
import { PageSection } from "../components/PageSection.jsx";
import { PlaylistGrid } from "../components/PlaylistGrid.jsx";
import { TrackList } from "../components/TrackList.jsx";
import { allTracks, playlistCards } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { LibraryPageFrame } from "./LibraryPageFrame.jsx";

export function RadioPage({ refresh }) {
  const playlists = usePlayerStore((s) => s.playlists);
  const tracks = allTracks(playlists);

  return (
    <LibraryPageFrame refresh={refresh}>
      <PageSection title="Stations" subtitle="Playlist-based stations for lean-back listening.">
        <PlaylistGrid playlists={playlistCards(playlists).slice(0, 6)} />
      </PageSection>
      <PageSection title="On Rotation" subtitle="A radio queue from your saved music.">
        <TrackList tracks={tracks.slice(0, 12)} refresh={refresh} />
      </PageSection>
    </LibraryPageFrame>
  );
}
