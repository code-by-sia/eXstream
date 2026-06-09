import React from "react";
import { useLocation } from "react-router-dom";
import { AppFrame } from "../components/AppFrame.jsx";
import { LibraryActions } from "../components/LibraryActions.jsx";
import { PageHero } from "../components/PageHero.jsx";
import { RouteSync } from "../components/RouteSync.jsx";
import { featuredTrack, pageCopy } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function LibraryPageFrame({ children, heroTrack, refresh, subtitle, title }) {
  const location = useLocation();
  const playlists = usePlayerStore((s) => s.playlists);
  const [defaultTitle, defaultSubtitle] = pageCopy(location.pathname);
  const heroTitle = title || defaultTitle;

  return (
    <AppFrame refresh={refresh}>
      <RouteSync />
      <section className="min-h-0 overflow-y-auto p-4 md:p-6 lg:p-8">
        <div className="mx-auto grid max-w-7xl gap-8">
          <PageHero
            title={heroTitle}
            subtitle={subtitle || defaultSubtitle}
            track={heroTrack || featuredTrack(playlists)}
            actions={<LibraryActions refresh={refresh} />}
          />
          {children}
        </div>
      </section>
    </AppFrame>
  );
}
