import React from "react";
import { PlayerBar } from "../components/PlayerBar.jsx";
import { Sidebar } from "../components/Sidebar.jsx";
import { Toolbar } from "../components/Toolbar.jsx";
import { TrackPanel } from "../components/TrackPanel.jsx";
import { RouteSync } from "../components/RouteSync.jsx";
import { TopMenu } from "../components/TopMenu.jsx";

export function MusicLayout({ refresh }) {
  return (
    <main className="min-h-screen bg-background p-0 sm:p-4">
      <RouteSync />
      <section className="mx-auto grid min-h-screen max-w-[1440px] overflow-hidden border-border bg-card shadow-sm sm:min-h-[calc(100vh-2rem)] sm:rounded-lg sm:border">
        <TopMenu />
        <section className="grid min-h-0 lg:grid-cols-[280px_1fr]">
          <Sidebar refresh={refresh} />
          <section className="grid min-w-0 grid-rows-[auto_1fr_auto] lg:border-l lg:border-border">
            <Toolbar refresh={refresh} />
            <TrackPanel />
            <PlayerBar />
          </section>
        </section>
      </section>
    </main>
  );
}
