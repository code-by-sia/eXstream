import React from "react";
import { Link, useLocation } from "react-router-dom";
import { SidebarGroup, SidebarGroupLabel, SidebarMenu, SidebarMenuButton } from "./ui/sidebar.jsx";

export function SidebarSection({ action, className, title, items }) {
  const location = useLocation();
  const activeFor = (to) => location.pathname === to;

  return (
    <SidebarGroup className={className}>
      <div className="ui-sidebar-label-row">
        <SidebarGroupLabel>{title}</SidebarGroupLabel>
        {action}
      </div>
      <SidebarMenu>
        {items.map(({ label, to, icon: Icon }) => (
          <Link key={`${label}-${to}`} to={to}>
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
