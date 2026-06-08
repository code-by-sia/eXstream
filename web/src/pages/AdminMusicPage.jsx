import React from "react";
import { Navigate } from "react-router-dom";
import { AdminMusicManager } from "../components/AdminMusicManager.jsx";
import { Sidebar } from "../components/Sidebar.jsx";
import { PlayerBar } from "../components/PlayerBar.jsx";
import { TopMenu } from "../components/TopMenu.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function AdminMusicPage({ refresh }) {
  const profile = usePlayerStore((s) => s.profile);

  if (profile && profile.role !== "ADMIN") return <Navigate to="/" replace />;

  return (
    <main className="min-h-screen bg-background p-0 sm:p-4">
      <section className="mx-auto grid min-h-screen max-w-[1440px] overflow-hidden border-border bg-card shadow-sm sm:min-h-[calc(100vh-2rem)] sm:rounded-lg sm:border">
        <TopMenu />
        <section className="grid min-h-0 lg:grid-cols-[280px_1fr]">
          <Sidebar refresh={refresh} />
          <section className="grid min-w-0 grid-rows-[1fr_auto] lg:border-l lg:border-border">
            <AdminMusicManager refresh={refresh} />
            <PlayerBar />
          </section>
        </section>
      </section>
    </main>
  );
}
