import React from "react";
import { Play } from "lucide-react";
import { CoverImage } from "./CoverImage.jsx";
import { TrackAdminActions } from "./TrackAdminActions.jsx";
import { isCurrentTrack, usePlayerStore } from "../store/usePlayerStore.js";

function NowPlayingBars() {
  return (
    <span className="now-playing-bars" aria-label="Now playing">
      <span />
      <span />
      <span />
    </span>
  );
}

export function TrackList({ refresh, tracks }) {
  const setNowPlaying = usePlayerStore((s) => s.setNowPlaying);
  const nowPlaying = usePlayerStore((s) => s.nowPlaying);
  const isPlaying = usePlayerStore((s) => s.isPlaying);

  if (!tracks.length) return <p className="track-empty">No songs found.</p>;
  return (
    <div className="track-list">
      {tracks.map((track, index) => {
        const current = isCurrentTrack(nowPlaying, track);
        return (
          <div
            key={`${track.playlistId}-${track.id}`}
            className={current ? "track-row track-row-current" : "track-row"}
            onClick={() => setNowPlaying(track, tracks)}
          >
            <button type="button" className="track-row-index" aria-label={`Play ${track.title}`}>
              {current && isPlaying ? (
                <NowPlayingBars />
              ) : (
                <>
                  <span className="track-row-index-number">{index + 1}</span>
                  <Play className="icon-xs icon-fill-current track-row-index-play" />
                </>
              )}
            </button>
            <CoverImage track={track} className="cover-size-12" />
            <span className="track-row-meta">
              <span className="track-row-title">{track.title}</span>
              <span className="track-row-subtitle">{track.artist || "Unknown artist"}</span>
            </span>
            <span className="track-row-context">{track.playlistName || "Library"}</span>
            <TrackAdminActions track={track} refresh={refresh} />
          </div>
        );
      })}
    </div>
  );
}
