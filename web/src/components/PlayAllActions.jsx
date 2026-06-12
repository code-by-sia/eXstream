import React from "react";
import { Play, Shuffle } from "lucide-react";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";

function shuffled(tracks) {
  const copy = [...tracks];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

export function PlayAllActions({ tracks }) {
  const setNowPlaying = usePlayerStore((s) => s.setNowPlaying);

  if (!tracks.length) return null;

  function playShuffled() {
    const queue = shuffled(tracks);
    setNowPlaying(queue[0], queue);
  }

  return (
    <div className="hero-play-actions">
      <Button type="button" onClick={() => setNowPlaying(tracks[0], tracks)}>
        <Play className="button-icon-gap icon-fill-current" /> Play
      </Button>
      <Button type="button" variant="outline" onClick={playShuffled}>
        <Shuffle className="button-icon-gap" /> Shuffle
      </Button>
    </div>
  );
}
