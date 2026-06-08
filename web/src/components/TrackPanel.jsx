import React from "react";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { AlbumCard } from "./AlbumCard.jsx";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "./ui/card.jsx";

function allTracks(playlists) {
  return playlists.flatMap((playlist) => playlist.tracks.map((track) => ({ ...track, playlistName: playlist.name })));
}

function TrackSection({ title, subtitle, tracks, onPlay, compact = false }) {
  return (
    <Card className="border-transparent shadow-none">
      <CardHeader className="px-0">
        <CardTitle className="text-2xl">{title}</CardTitle>
        <CardDescription>{subtitle}</CardDescription>
      </CardHeader>
      <CardContent className="px-0">
        <div className={compact ? "grid grid-cols-[repeat(auto-fill,minmax(140px,1fr))] gap-4" : "grid grid-cols-[repeat(auto-fill,minmax(190px,1fr))] gap-5"}>
          {tracks.map((track) => <AlbumCard key={track.id} track={track} onPlay={() => onPlay(track)} />)}
        </div>
      </CardContent>
    </Card>
  );
}

export function TrackPanel() {
  const playlists = usePlayerStore((s) => s.playlists);
  const selected = usePlayerStore((s) => s.selected);
  const setNowPlaying = usePlayerStore((s) => s.setNowPlaying);
  const tracks = selected?.tracks?.length ? selected.tracks : allTracks(playlists);
  const madeForYou = allTracks(playlists).slice(0, 8);

  return (
    <section className="grid content-start gap-8 bg-card px-5 pb-8 lg:px-8">
      {tracks.length === 0 && <p className="text-sm text-muted">No tracks yet. Admins can add music from the Add music page.</p>}
      <TrackSection title="Listen Now" subtitle="Top picks for you. Updated daily." tracks={tracks.slice(0, 4)} onPlay={setNowPlaying} />
      <TrackSection title="Made for You" subtitle="Your personal playlists. Updated daily." tracks={madeForYou} onPlay={setNowPlaying} compact />
    </section>
  );
}
