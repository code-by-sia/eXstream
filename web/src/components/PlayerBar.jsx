import React from "react";
import { useEffect, useRef, useState } from "react";
import { Pause, Play, SkipBack, SkipForward, Volume2 } from "lucide-react";
import { resolveTrackSource } from "../api/files.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { CoverImage } from "./CoverImage.jsx";

function formatTime(seconds) {
  if (!Number.isFinite(seconds)) return "0:00";
  const whole = Math.floor(seconds);
  return `${Math.floor(whole / 60)}:${String(whole % 60).padStart(2, "0")}`;
}

export function PlayerBar() {
  const audio = useRef(undefined);
  const track = usePlayerStore((s) => s.nowPlaying);
  const token = usePlayerStore((s) => s.token);
  const isPlaying = usePlayerStore((s) => s.isPlaying);
  const setIsPlaying = usePlayerStore((s) => s.setIsPlaying);
  const playNext = usePlayerStore((s) => s.playNext);
  const playPrevious = usePlayerStore((s) => s.playPrevious);
  const [source, setSource] = useState("");
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [volume, setVolume] = useState(1);

  useEffect(() => {
    if (!track) { setSource(""); return; }
    resolveTrackSource(token, track.url).then(setSource).catch(() => setSource(""));
  }, [track, token]);

  useEffect(() => {
    if (!audio.current) return;
    setCurrentTime(0);
    setDuration(0);
    if (!source) { audio.current.removeAttribute("src"); return; }
    audio.current.src = source;
    audio.current.load();
    audio.current.play().catch(() => {});
  }, [source]);

  function togglePlay() {
    if (!audio.current || !source) return;
    if (audio.current.paused) audio.current.play().catch(() => {});
    else audio.current.pause();
  }

  function seek(event) {
    if (!audio.current) return;
    const time = Number(event.target.value);
    audio.current.currentTime = time;
    setCurrentTime(time);
  }

  function changeVolume(event) {
    const level = Number(event.target.value);
    setVolume(level);
    if (audio.current) audio.current.volume = level;
  }

  const progressFill = duration ? `${(currentTime / duration) * 100}%` : "0%";

  return (
    <footer className="player-bar">
      <div className="player-track">
        <CoverImage track={track} className="player-cover" />
        <div className="player-meta">
          <strong className="player-title">{track?.title || "Nothing playing"}</strong>
          <span className="player-subtitle">{track?.artist || "Select a track to start listening"}</span>
        </div>
      </div>
      <div className="player-center">
        <div className="player-controls">
          <button type="button" className="player-skip-button" onClick={playPrevious} disabled={!track} aria-label="Previous track">
            <SkipBack className="icon-sm icon-fill-current" />
          </button>
          <button type="button" className="player-play-button" onClick={togglePlay} disabled={!source} aria-label={isPlaying ? "Pause" : "Play"}>
            {isPlaying ? <Pause className="icon-sm icon-fill-current" /> : <Play className="icon-sm icon-fill-current" />}
          </button>
          <button type="button" className="player-skip-button" onClick={playNext} disabled={!track} aria-label="Next track">
            <SkipForward className="icon-sm icon-fill-current" />
          </button>
        </div>
        <div className="player-timeline">
          <span className="player-time">{formatTime(currentTime)}</span>
          <input
            type="range"
            className="player-range"
            style={{ "--fill": progressFill }}
            min="0"
            max={duration || 0}
            step="0.1"
            value={currentTime}
            onChange={seek}
            disabled={!duration}
            aria-label="Seek"
          />
          <span className="player-time">{formatTime(duration)}</span>
        </div>
      </div>
      <div className="player-side">
        <Volume2 className="player-volume-icon" />
        <input
          type="range"
          className="player-range player-volume-range"
          style={{ "--fill": `${volume * 100}%` }}
          min="0"
          max="1"
          step="0.01"
          value={volume}
          onChange={changeVolume}
          aria-label="Volume"
        />
      </div>
      <audio
        ref={audio}
        className="player-audio"
        onPlay={() => setIsPlaying(true)}
        onPause={() => setIsPlaying(false)}
        onEnded={playNext}
        onTimeUpdate={(event) => setCurrentTime(event.target.currentTime)}
        onLoadedMetadata={(event) => setDuration(event.target.duration)}
      />
    </footer>
  );
}
