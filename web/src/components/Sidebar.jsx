import React from "react";
import { LogOut } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { LibraryNav } from "./LibraryNav.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { ThemeToggle } from "./ThemeToggle.jsx";
import { SidebarContent, SidebarFooter, SidebarHeader, SidebarShell } from "./ui/sidebar.jsx";

export function Sidebar({ refresh }) {
  const logout = usePlayerStore((s) => s.logout);
  const profile = usePlayerStore((s) => s.profile);
  const navigate = useNavigate();
  const avatar = profile?.avatar || "🎧";
  const name = profile?.profileName || profile?.username || "Signed out";

  function signOut() {
    logout();
    navigate("/login");
  }

  return (
    <SidebarShell className="app-sidebar">
      <SidebarHeader>
        <div className="sidebar-brand">
          <img src="/icons/icon.svg" alt="" className="sidebar-logo" />
          <h1 className="sidebar-title">eXstream</h1>
        </div>
      </SidebarHeader>
      <SidebarContent>
        <LibraryNav refresh={refresh} />
      </SidebarContent>
      <SidebarFooter>
        <div className="sidebar-profile">
          <span className="sidebar-profile-avatar">{avatar}</span>
          <div className="sidebar-profile-info">
            <p className="sidebar-profile-name">{name}</p>
            <p className="sidebar-profile-username">{profile?.role === "ADMIN" ? `${profile?.username} · admin` : profile?.username || "Signed out"}</p>
          </div>
          <div className="sidebar-profile-actions">
            <ThemeToggle />
            <button type="button" className="sidebar-icon-button" onClick={signOut} aria-label="Log out">
              <LogOut className="icon-sm" />
            </button>
          </div>
        </div>
      </SidebarFooter>
    </SidebarShell>
  );
}
