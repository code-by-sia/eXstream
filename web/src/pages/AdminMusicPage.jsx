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
    <main className="min-h-screen bg-background">
      <TopMenu />
      <section className="grid min-h-[calc(100vh-2.5rem)] lg:grid-cols-5">
        <Sidebar refresh={refresh} />
        <section className="grid min-w-0 grid-rows-[1fr_auto] lg:col-span-4 lg:border-l lg:border-border">
          <AdminMusicManager refresh={refresh} />
          <PlayerBar />
        </section>
      </section>
    </main>
  );
}
