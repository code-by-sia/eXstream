import React from "react";

const covers = [
  "https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=600&q=80",
  "https://images.unsplash.com/photo-1507838153414-b4b713384a76?auto=format&fit=crop&w=600&q=80",
  "https://images.unsplash.com/photo-1485579149621-3123dd979885?auto=format&fit=crop&w=600&q=80",
  "https://images.unsplash.com/photo-1511379938547-c1f69419868d?auto=format&fit=crop&w=600&q=80",
  "https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?auto=format&fit=crop&w=600&q=80",
  "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?auto=format&fit=crop&w=600&q=80",
];

export function coverForTrack(track) {
  const key = `${track?.title || ""}${track?.artist || ""}`;
  const sum = key.split("").reduce((total, char) => total + char.charCodeAt(0), 0);
  return covers[sum % covers.length];
}

export function CoverImage({ track, className = "aspect-square" }) {
  return <img src={coverForTrack(track)} alt="" className={`w-full rounded-md object-cover ${className}`} loading="lazy" />;
}
