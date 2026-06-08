import React from "react";
import { cn } from "../../lib/utils.js";

export function Menubar({ className, ...props }) {
  return <nav className={cn("flex h-10 items-center gap-1 border-b border-border bg-background px-2 shadow-sm lg:px-4", className)} {...props} />;
}

export function MenubarItem({ className, active, ...props }) {
  return (
    <span
      className={cn("rounded-sm px-3 py-1 text-sm font-medium hover:bg-accent", active && "font-bold", className)}
      {...props}
    />
  );
}
