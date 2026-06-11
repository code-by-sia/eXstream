import React from "react";
import { CoverImage } from "./CoverImage.jsx";

export function PageHero({ actions, kicker = "eXstream", subtitle, title, track }) {
  return (
    <header className="page-hero">
      <div className="page-hero-body">
        <p className="page-hero-kicker">{kicker}</p>
        <div className="page-hero-copy">
          <h1 className="page-hero-title">{title}</h1>
          <p className="page-hero-subtitle">{subtitle}</p>
        </div>
        {actions}
      </div>
      {track ? (
        <div className="page-hero-cover">
          <CoverImage track={track} className="page-hero-image" />
        </div>
      ) : null}
    </header>
  );
}
