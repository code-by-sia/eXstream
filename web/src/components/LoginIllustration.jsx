import React from "react";

// undraw-style flat illustration (music / listening), drawn on the brand
// panel's gradient. Uses light tones plus one warm accent so it reads on the
// coloured background without external assets.
export function LoginIllustration() {
  return (
    <svg className="auth-illustration" viewBox="0 0 440 340" fill="none" xmlns="http://www.w3.org/2000/svg" role="img" aria-label="Listening to music">
      <defs>
        <linearGradient id="discFace" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#ffffff" stopOpacity="0.95" />
          <stop offset="1" stopColor="#ffffff" stopOpacity="0.7" />
        </linearGradient>
      </defs>

      {/* soft backdrop blobs */}
      <circle cx="350" cy="70" r="120" fill="#ffffff" opacity="0.06" />
      <circle cx="80" cy="280" r="90" fill="#ffffff" opacity="0.06" />

      {/* equalizer bars */}
      <g opacity="0.85">
        <rect x="36" y="150" width="14" height="70" rx="7" fill="#ffffff" opacity="0.55" />
        <rect x="58" y="120" width="14" height="100" rx="7" fill="#ffffff" opacity="0.75" />
        <rect x="80" y="92" width="14" height="128" rx="7" fill="#ffd166" />
        <rect x="102" y="132" width="14" height="88" rx="7" fill="#ffffff" opacity="0.75" />
        <rect x="124" y="108" width="14" height="112" rx="7" fill="#ffffff" opacity="0.55" />
      </g>

      {/* vinyl record */}
      <g transform="translate(280 175)">
        <circle r="105" fill="#1f2430" opacity="0.55" />
        <circle r="105" fill="none" stroke="#ffffff" strokeOpacity="0.18" strokeWidth="2" />
        <circle r="84" fill="none" stroke="#ffffff" strokeOpacity="0.14" strokeWidth="2" />
        <circle r="64" fill="none" stroke="#ffffff" strokeOpacity="0.14" strokeWidth="2" />
        <circle r="40" fill="url(#discFace)" />
        <circle r="10" fill="#ffd166" />
      </g>

      {/* floating notes */}
      <g fill="#ffffff">
        <g opacity="0.9" transform="translate(196 70)">
          <rect x="22" y="-6" width="5" height="44" rx="2.5" />
          <circle cx="14" cy="40" r="9" />
          <path d="M27 -6 C40 -2 44 6 40 16 L27 12 Z" />
        </g>
        <g opacity="0.6" transform="translate(150 36)">
          <rect x="14" y="-4" width="4" height="30" rx="2" />
          <circle cx="9" cy="27" r="6" />
        </g>
      </g>
    </svg>
  );
}
