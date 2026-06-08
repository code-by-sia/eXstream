import React from "react";
import { useEffect, useRef } from "react";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function PlayerBar() {
  const audio = useRef(undefined);
  const track = usePlayerStore((s) => s.nowPlaying);

  useEffect(() => {
    if (!track || !audio.current) return;
    audio.current.load();
    audio.current.play().catch(() => {});
  }, [track]);

  return (
    <footer className="grid grid-cols-[1fr_minmax(260px,520px)] items-center gap-5 border-t border-border bg-white p-5 max-lg:grid-cols-1">
      <div className="grid gap-1">
        <strong>{track?.title || "Nothing playing"}</strong>
        <span className="text-sm text-muted">{track?.artist || ""}</span>
      </div>
      <audio ref={audio} controls className="w-full">
        {track?.url && <source src={track.url} />}
      </audio>
    </footer>
  );
}
