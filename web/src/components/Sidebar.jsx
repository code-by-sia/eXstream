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
    <SidebarShell className="app-sidebar">
      <SidebarHeader>
        <div className="sidebar-brand">
          <img src="/icons/icon.svg" alt="" className="sidebar-logo" />
          <div>
            <h1 className="sidebar-title">eXstream</h1>
            <p className="sidebar-subtitle">Stream library</p>
          </div>
        </div>
        <ProfileSummary />
      </SidebarHeader>
      <SidebarContent>
        <LibraryNav />
      </SidebarContent>
      <Separator />
      <SidebarFooter>
        <div className="sidebar-footer-actions">
          <Button type="button" variant="outline" onClick={signOut}>Logout</Button>
          <ThemeToggle />
        </div>
        <div className="sidebar-desktop-only">
          <PlaylistCreator refresh={refresh} />
        </div>
      </SidebarFooter>
    </SidebarShell>
  );
}
