import React from "react";
import { PlayerBar } from "../components/PlayerBar.jsx";
import { PlaylistList } from "../components/PlaylistList.jsx";
import { Sidebar } from "../components/Sidebar.jsx";
import { Toolbar } from "../components/Toolbar.jsx";
import { TrackPanel } from "../components/TrackPanel.jsx";
import { RouteSync } from "../components/RouteSync.jsx";

export function MusicLayout({ refresh }) {
  return (
    <main className="grid min-h-screen grid-cols-[320px_1fr] max-lg:grid-cols-1">
      <RouteSync />
      <Sidebar refresh={refresh} />
      <section className="grid min-w-0 grid-rows-[auto_1fr_auto]">
        <Toolbar refresh={refresh} />
        <section className="grid min-h-0 grid-cols-[minmax(260px,420px)_1fr] gap-5 p-6 max-lg:grid-cols-1">
          <PlaylistList />
          <TrackPanel refresh={refresh} />
        </section>
        <PlayerBar />
      </section>
    </main>
  );
}
