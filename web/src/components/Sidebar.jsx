import React from "react";
import { useNavigate } from "react-router-dom";
import { LibraryNav } from "./LibraryNav.jsx";
import { PlaylistCreator } from "./PlaylistCreator.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { ProfileSummary } from "./ProfileSummary.jsx";

export function Sidebar({ refresh }) {
  const logout = usePlayerStore((s) => s.logout);
  const navigate = useNavigate();

  function signOut() {
    logout();
    navigate("/login");
  }

  return (
    <aside className="grid content-start gap-6 border-r border-border bg-card p-5 max-lg:border-r-0 max-lg:border-b">
      <div className="flex items-center gap-3">
        <span className="grid h-11 w-11 place-items-center rounded-md bg-foreground font-bold text-white">X</span>
        <div>
          <h1 className="text-2xl font-bold leading-none">eXstream</h1>
          <p className="mt-1 text-sm text-muted">Music, files, playlists</p>
        </div>
      </div>
      <ProfileSummary />
      <LibraryNav />
      <Button type="button" variant="outline" onClick={signOut}>Logout</Button>
      <PlaylistCreator refresh={refresh} />
    </aside>
  );
}
