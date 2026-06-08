import React from "react";
import { Navigate } from "react-router-dom";
import { AdminMusicManager } from "../components/AdminMusicManager.jsx";
import { Sidebar } from "../components/Sidebar.jsx";
import { PlayerBar } from "../components/PlayerBar.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function AdminMusicPage({ refresh }) {
  const profile = usePlayerStore((s) => s.profile);

  if (profile && profile.role !== "ADMIN") return <Navigate to="/" replace />;

  return (
    <main className="grid min-h-screen grid-cols-[320px_1fr] max-lg:grid-cols-1">
      <Sidebar refresh={refresh} />
      <section className="grid min-w-0 grid-rows-[1fr_auto]">
        <AdminMusicManager refresh={refresh} />
        <PlayerBar />
      </section>
    </main>
  );
}
