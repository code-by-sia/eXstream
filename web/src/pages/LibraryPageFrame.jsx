import React from "react";
import { useLocation } from "react-router-dom";
import { LibraryActions } from "../components/LibraryActions.jsx";
import { PageHero } from "../components/PageHero.jsx";
import { RouteSync } from "../components/RouteSync.jsx";
import { featuredTrack, pageCopy } from "../lib/library.js";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function LibraryPageFrame({ children, heroExtras, heroTrack, refresh, subtitle, title }) {
  const location = useLocation();
  const playlists = usePlayerStore((s) => s.playlists);
  const [defaultTitle, defaultSubtitle] = pageCopy(location.pathname);
  const heroTitle = title || defaultTitle;

  return (
    <>
      <RouteSync />
      <section className="library-page-shell">
        <div className="library-page-content">
          <PageHero
            title={heroTitle}
            subtitle={subtitle || defaultSubtitle}
            track={heroTrack || featuredTrack(playlists)}
            actions={
              <>
                {heroExtras}
                <LibraryActions refresh={refresh} />
              </>
            }
          />
          {children}
        </div>
      </section>
    </>
  );
}
