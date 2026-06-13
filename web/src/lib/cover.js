// Deterministic placeholder artwork for tracks with no embedded album art.
// Generates a gradient + initial as an inline SVG so the UI never shows
// unrelated stock photos.
function hashNum(value) {
  let hash = 0;
  for (const char of value) hash = (hash * 31 + char.charCodeAt(0)) >>> 0;
  return hash;
}

export function placeholderCover(track) {
  const key = `${track?.title || ""}${track?.artist || ""}` || "eXstream";
  const hash = hashNum(key);
  const hue1 = hash % 360;
  const hue2 = (hash * 7) % 360;
  const letter = (track?.title || "♪").trim().charAt(0).toUpperCase() || "♪";
  const svg =
    `<svg xmlns='http://www.w3.org/2000/svg' width='300' height='300'>` +
    `<defs><linearGradient id='g' x1='0' y1='0' x2='1' y2='1'>` +
    `<stop offset='0' stop-color='hsl(${hue1} 65% 48%)'/>` +
    `<stop offset='1' stop-color='hsl(${hue2} 60% 30%)'/></linearGradient></defs>` +
    `<rect width='300' height='300' fill='url(#g)'/>` +
    `<text x='50%' y='50%' dy='.35em' text-anchor='middle' font-family='Inter,system-ui,sans-serif' ` +
    `font-size='150' font-weight='700' fill='rgba(255,255,255,.9)'>${letter}</text></svg>`;
  return `data:image/svg+xml;utf8,${encodeURIComponent(svg)}`;
}

// True for a cover that must be fetched from the file service (a cached path)
// rather than used directly as an <img src>.
export function isStoredCover(coverUrl) {
  return Boolean(coverUrl) && (coverUrl.startsWith("/file/") || coverUrl.startsWith("file/"));
}
