import React from "react";
import { PlayerBar } from "./PlayerBar.jsx";
import { Sidebar } from "./Sidebar.jsx";
import { TopMenu } from "./TopMenu.jsx";

export function AppFrame({ refresh, children, player = true }) {
  return (
    <main className="min-h-screen w-full bg-background">
      <section className="mx-auto grid min-h-screen overflow-hidden border-border bg-card shadow-sm sm:min-h-[calc(100vh-2rem)] sm:rounded-lg sm:border">
        <TopMenu />
        <section className="grid min-h-0 lg:grid-cols-[280px_1fr]">
          <Sidebar refresh={refresh} />
          <section className="grid min-w-0 grid-rows-[1fr_auto] lg:border-l lg:border-border">
            {children}
            {player && <PlayerBar />}
          </section>
        </section>
      </section>
    </main>
  );
}
