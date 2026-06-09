import React from "react";
import { cn } from "../../lib/utils.js";

export function SidebarShell({ className, ...props }) {
  return <aside className={cn("grid content-start gap-5 border-r border-border p-4", className)} {...props} />;
}

export function SidebarHeader({ className, ...props }) {
  return <div className={cn("grid gap-4", className)} {...props} />;
}

export function SidebarContent({ className, ...props }) {
  return <div className={cn("grid gap-7 max-lg:gap-4", className)} {...props} />;
}

export function SidebarFooter({ className, ...props }) {
  return <div className={cn("grid gap-3", className)} {...props} />;
}

export function SidebarGroup({ className, ...props }) {
  return <div className={cn("grid gap-2", className)} {...props} />;
}

export function SidebarGroupLabel({ className, ...props }) {
  return <h2 className={cn("px-3 text-xs font-semibold uppercase tracking-wide text-muted", className)} {...props} />;
}

export function SidebarMenu({ className, ...props }) {
  return <div className={cn("grid gap-1 max-lg:grid-cols-2", className)} {...props} />;
}

export function SidebarMenuButton({ className, active, ...props }) {
  return (
    <div
      className={cn(
        "flex min-h-10 items-center gap-3 rounded-md px-3 text-sm font-medium transition hover:bg-accent",
        active ? "bg-foreground text-background shadow-sm" : "text-foreground",
        className
      )}
      {...props}
    />
  );
}
