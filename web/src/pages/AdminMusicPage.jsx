import React from "react";
import { Navigate } from "react-router-dom";
import { AppFrame } from "../components/AppFrame.jsx";
import { AdminMusicManager } from "../components/AdminMusicManager.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function AdminMusicPage({ refresh }) {
  const profile = usePlayerStore((s) => s.profile);

  if (profile && profile.role !== "ADMIN") return <Navigate to="/" replace />;

  return (
    <AppFrame refresh={refresh}>
      <AdminMusicManager refresh={refresh} />
    </AppFrame>
  );
}
