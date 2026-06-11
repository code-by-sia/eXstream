import React from "react";
import { cn } from "../../lib/utils.js";

export function SidebarShell({ className, ...props }) {
  return <aside className={cn("ui-sidebar", className)} {...props} />;
}

export function SidebarHeader({ className, ...props }) {
  return <div className={cn("ui-sidebar-header", className)} {...props} />;
}

export function SidebarContent({ className, ...props }) {
  return <div className={cn("ui-sidebar-content", className)} {...props} />;
}

export function SidebarFooter({ className, ...props }) {
  return <div className={cn("ui-sidebar-footer", className)} {...props} />;
}

export function SidebarGroup({ className, ...props }) {
  return <div className={cn("ui-sidebar-group", className)} {...props} />;
}

export function SidebarGroupLabel({ className, ...props }) {
  return <h2 className={cn("ui-sidebar-label", className)} {...props} />;
}

export function SidebarMenu({ className, ...props }) {
  return <div className={cn("ui-sidebar-menu", className)} {...props} />;
}

export function SidebarMenuButton({ className, active, ...props }) {
  return (
    <div
      className={cn(
        "ui-sidebar-button",
        active && "ui-sidebar-button-active",
        className
      )}
      {...props}
    />
  );
}
