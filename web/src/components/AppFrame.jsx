import React from "react";
import { Outlet } from "react-router-dom";
import { PlayerBar } from "./PlayerBar.jsx";
import { Sidebar } from "./Sidebar.jsx";

export function AppFrame({ refresh }) {
  return (
    <main className="app-shell">
      <section className="app-grid">
        <Sidebar refresh={refresh} />
        <section className="app-content">
          <Outlet />
          <PlayerBar />
        </section>
      </section>
    </main>
  );
}
