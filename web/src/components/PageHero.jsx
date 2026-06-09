import React from "react";
import { CoverImage } from "./CoverImage.jsx";

export function PageHero({ actions, kicker = "eXstream", subtitle, title, track }) {
  return (
    <header className="grid gap-5 rounded-lg bg-gradient-to-br from-foreground/[0.08] via-card to-primary/[0.12] p-5 md:grid-cols-[1fr_auto] md:p-7">
      <div className="grid content-end gap-3">
        <p className="text-xs font-semibold uppercase tracking-wide text-muted">{kicker}</p>
        <div className="grid gap-2">
          <h1 className="break-words text-4xl font-black leading-none md:text-6xl">{title}</h1>
          <p className="max-w-2xl text-sm text-muted md:text-base">{subtitle}</p>
        </div>
        {actions}
      </div>
      {track ? (
        <div className="hidden w-40 md:block lg:w-52">
          <CoverImage track={track} className="aspect-square w-full shadow-2xl" />
        </div>
      ) : null}
    </header>
  );
}
