import React from "react";
import { Link, useLocation } from "react-router-dom";
import { SidebarGroup, SidebarGroupLabel, SidebarMenu, SidebarMenuButton } from "./ui/sidebar.jsx";

export function SidebarSection({ title, items }) {
  const location = useLocation();

  return (
    <SidebarGroup>
      <SidebarGroupLabel>{title}</SidebarGroupLabel>
      <SidebarMenu>
        {items.map(({ label, to, icon: Icon }) => (
          <Link key={label} to={to}>
            <SidebarMenuButton active={location.pathname === to}>
              {Icon && <Icon className="h-4 w-4" />}
              <span className="truncate">{label}</span>
            </SidebarMenuButton>
          </Link>
        ))}
      </SidebarMenu>
    </SidebarGroup>
  );
}
