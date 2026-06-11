import React from "react";
import { PlayerBar } from "./PlayerBar.jsx";
import { Sidebar } from "./Sidebar.jsx";

export function AppFrame({ refresh, children, player = true }) {
  return (
    <main className="app-shell">
      <section className="app-grid">
        <Sidebar refresh={refresh} />
        <section className="app-content">
          {children}
          {player && <PlayerBar />}
        </section>
      </section>
    </main>
  );
}
