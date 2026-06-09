import React from "react";
import { PlayerBar } from "./PlayerBar.jsx";
import { Sidebar } from "./Sidebar.jsx";

export function AppFrame({ refresh, children, player = true }) {
  return (
    <main className="min-h-screen w-full bg-background text-foreground">
      <section className="grid min-h-screen overflow-hidden lg:grid-cols-[292px_1fr]">
        <Sidebar refresh={refresh} />
        <section className="grid min-w-0 grid-rows-[1fr_auto] border-border bg-card/95 lg:border-l">
          {children}
          {player && <PlayerBar />}
        </section>
      </section>
    </main>
  );
}
