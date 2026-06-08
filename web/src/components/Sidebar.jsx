import React from "react";
import { useNavigate } from "react-router-dom";
import { LibraryNav } from "./LibraryNav.jsx";
import { PlaylistCreator } from "./PlaylistCreator.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { ProfileSummary } from "./ProfileSummary.jsx";
import { Separator } from "./ui/separator.jsx";
import { SidebarContent, SidebarFooter, SidebarHeader, SidebarShell } from "./ui/sidebar.jsx";

export function Sidebar({ refresh }) {
  const logout = usePlayerStore((s) => s.logout);
  const navigate = useNavigate();

  function signOut() {
    logout();
    navigate("/login");
  }

  return (
    <SidebarShell className="max-lg:border-r-0 max-lg:border-b">
      <SidebarHeader>
        <div className="flex items-center gap-3">
          <span className="grid h-11 w-11 place-items-center rounded-md bg-foreground font-bold text-background">X</span>
          <div>
            <h1 className="text-2xl font-bold leading-none">eXstream</h1>
            <p className="mt-1 text-sm text-muted">Music, files, playlists</p>
          </div>
        </div>
        <ProfileSummary />
      </SidebarHeader>
      <SidebarContent><LibraryNav /></SidebarContent>
      <Separator />
      <SidebarFooter>
        <Button type="button" variant="outline" onClick={signOut}>Logout</Button>
        <PlaylistCreator refresh={refresh} />
      </SidebarFooter>
    </SidebarShell>
  );
}
