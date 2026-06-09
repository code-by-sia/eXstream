import React from "react";
import { useEffect, useRef } from "react";
import { resolveTrackSource } from "../api/files.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { CoverImage } from "./CoverImage.jsx";

export function PlayerBar() {
  const audio = useRef(undefined);
  const track = usePlayerStore((s) => s.nowPlaying);
  const token = usePlayerStore((s) => s.token);
  const [source, setSource] = React.useState("");

  useEffect(() => {
    if (!track) { setSource(""); return; }
    resolveTrackSource(token, track.url).then(setSource).catch(() => setSource(""));
  }, [track, token]);

  useEffect(() => {
    if (!source || !audio.current) return;
    audio.current.load();
    audio.current.play().catch(() => {});
  }, [source]);

  return (
    <footer className="grid gap-4 border-t border-border bg-background/90 p-4 backdrop-blur md:grid-cols-[minmax(220px,1fr)_minmax(260px,560px)] md:items-center">
      <div className="grid grid-cols-[3.5rem_1fr] items-center gap-3">
        <CoverImage track={track} className="size-14 shadow-md" />
        <div className="min-w-0">
          <strong className="block truncate">{track?.title || "Nothing playing"}</strong>
          <span className="block truncate text-sm text-muted">{track?.artist || "Select a track"}</span>
        </div>
      </div>
      <audio ref={audio} controls className="w-full">
        {source && <source src={source} />}
      </audio>
    </footer>
  );
}
