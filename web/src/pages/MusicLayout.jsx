import React from "react";
import { PlayerBar } from "../components/PlayerBar.jsx";
import { PlaylistList } from "../components/PlaylistList.jsx";
import { Sidebar } from "../components/Sidebar.jsx";
import { Toolbar } from "../components/Toolbar.jsx";
import { TrackPanel } from "../components/TrackPanel.jsx";
import { RouteSync } from "../components/RouteSync.jsx";
import { TopMenu } from "../components/TopMenu.jsx";

export function MusicLayout({ refresh }) {
  return (
    <main className="min-h-screen bg-background">
      <RouteSync />
      <TopMenu />
      <section className="grid min-h-[calc(100vh-2.5rem)] lg:grid-cols-5">
        <Sidebar refresh={refresh} />
        <section className="grid min-w-0 grid-rows-[auto_1fr_auto] lg:col-span-4 lg:border-l lg:border-border">
          <Toolbar refresh={refresh} />
          <section className="grid min-h-0 grid-cols-[minmax(240px,360px)_1fr] gap-5 p-4 max-lg:grid-cols-1 lg:p-6">
            <PlaylistList />
            <TrackPanel refresh={refresh} />
          </section>
          <PlayerBar />
        </section>
      </section>
    </main>
  );
}
