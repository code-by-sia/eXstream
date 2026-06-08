import React from "react";
import { AppFrame } from "../components/AppFrame.jsx";
import { Toolbar } from "../components/Toolbar.jsx";
import { TrackPanel } from "../components/TrackPanel.jsx";
import { RouteSync } from "../components/RouteSync.jsx";

export function MusicLayout({ refresh }) {
  return (
    <AppFrame refresh={refresh}>
      <RouteSync />
      <section className="grid min-h-0 grid-rows-[auto_1fr]">
        <Toolbar refresh={refresh} />
        <TrackPanel />
      </section>
    </AppFrame>
  );
}
