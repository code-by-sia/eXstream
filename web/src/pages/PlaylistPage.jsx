import React from "react";
import { useParams } from "react-router-dom";
import { PageSection } from "../components/PageSection.jsx";
import { PlayAllActions } from "../components/PlayAllActions.jsx";
import { TrackList } from "../components/TrackList.jsx";
import { playlistById } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { LibraryPageFrame } from "./LibraryPageFrame.jsx";

export function PlaylistPage({ refresh }) {
  const { playlistId } = useParams();
  const playlists = usePlayerStore((s) => s.playlists);
  const selected = usePlayerStore((s) => s.selected);
  const playlist = playlistById(playlists, playlistId) || selected;
  const tracks = (playlist?.tracks || []).map((track) => ({ ...track, playlistId, playlistName: playlist?.name }));
  const subtitle = playlist ? `${tracks.length} tracks · ${playlist.owner}` : "Loading playlist.";

  return (
    <LibraryPageFrame
      refresh={refresh}
      title={playlist?.name || "Playlist"}
      subtitle={subtitle}
      heroTrack={tracks[0]}
      heroExtras={<PlayAllActions tracks={tracks} />}
    >
      <PageSection title="Songs" subtitle={playlist?.description}>
        <TrackList tracks={tracks} />
      </PageSection>
    </LibraryPageFrame>
  );
}
