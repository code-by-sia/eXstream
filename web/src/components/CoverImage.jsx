import React from "react";
import { useEffect, useState } from "react";
import { resolveCover } from "../api/files.js";
import { isStoredCover, placeholderCover } from "../lib/cover.js";
import { usePlayerStore } from "../store/usePlayerStore.js";

function directSource(track) {
  const cover = track?.coverUrl;
  if (cover && !isStoredCover(cover)) return cover;
  return placeholderCover(track);
}

export function CoverImage({ track, className = "cover-image-default" }) {
  const token = usePlayerStore((s) => s.token);
  const cover = track?.coverUrl;
  const [src, setSrc] = useState(() => directSource(track));

  useEffect(() => {
    let active = true;
    if (isStoredCover(cover)) {
      resolveCover(token, cover)
        .then((resolved) => { if (active && resolved) setSrc(resolved); })
        .catch(() => {});
    } else {
      setSrc(directSource(track));
    }
    return () => { active = false; };
  }, [cover, token]);

  return <img src={src} alt="" className={`cover-image ${className}`} loading="lazy" />;
}
