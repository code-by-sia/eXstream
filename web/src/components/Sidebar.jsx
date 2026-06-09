import React from "react";
import { useNavigate } from "react-router-dom";
import { LibraryNav } from "./LibraryNav.jsx";
import { PlaylistCreator } from "./PlaylistCreator.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { ProfileSummary } from "./ProfileSummary.jsx";
import { Separator } from "./ui/separator.jsx";
import { ThemeToggle } from "./ThemeToggle.jsx";
import { SidebarContent, SidebarFooter, SidebarHeader, SidebarShell } from "./ui/sidebar.jsx";

export function Sidebar({ refresh }) {
  const logout = usePlayerStore((s) => s.logout);
  const navigate = useNavigate();

  function signOut() {
    logout();
    navigate("/login");
  }

  return (
    <SidebarShell className="bg-background/90 backdrop-blur max-lg:border-r-0 max-lg:border-b">
      <SidebarHeader>
        <div className="flex items-center gap-3 rounded-md bg-card p-2 shadow-sm">
          <img src="/icons/icon.svg" alt="" className="h-12 w-12 rounded-md" />
          <div>
            <h1 className="text-xl font-bold leading-none">eXstream</h1>
            <p className="mt-1 text-xs text-muted">Stream library</p>
          </div>
        </div>
        <ProfileSummary />
      </SidebarHeader>
      <SidebarContent>
        <LibraryNav />
      </SidebarContent>
      <Separator />
      <SidebarFooter>
        <div className="grid grid-cols-[1fr_auto] gap-2">
          <Button type="button" variant="outline" onClick={signOut}>Logout</Button>
          <ThemeToggle />
        </div>
        <div className="max-lg:hidden">
          <PlaylistCreator refresh={refresh} />
        </div>
      </SidebarFooter>
    </SidebarShell>
  );
}
