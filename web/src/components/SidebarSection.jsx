import React from "react";
import { Link, useLocation } from "react-router-dom";
import { SidebarGroup, SidebarGroupLabel, SidebarMenu, SidebarMenuButton } from "./ui/sidebar.jsx";

export function SidebarSection({ className, title, items }) {
  const location = useLocation();
  const activeFor = (to) => (to === "/" ? location.pathname === to : location.pathname === to);

  return (
    <SidebarGroup className={className}>
      <SidebarGroupLabel>{title}</SidebarGroupLabel>
      <SidebarMenu>
        {items.map(({ label, to, icon: Icon }) => (
          <Link key={label} to={to}>
            <SidebarMenuButton active={activeFor(to)}>
              {Icon && <Icon className="sidebar-item-icon" />}
              <span className="sidebar-item-label">{label}</span>
            </SidebarMenuButton>
          </Link>
        ))}
      </SidebarMenu>
    </SidebarGroup>
  );
}
