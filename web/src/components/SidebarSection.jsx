import React from "react";
import { Link, useLocation } from "react-router-dom";
import { cn } from "../lib/utils.js";

export function SidebarSection({ title, items }) {
  const location = useLocation();

  return (
    <div className="grid gap-2">
      <h2 className="px-2 text-lg font-semibold">{title}</h2>
      <div className="grid gap-1">
        {items.map(({ label, to, icon: Icon }) => (
          <Link
            key={label}
            to={to}
            className={cn(
              "flex min-h-9 items-center gap-3 rounded-md px-3 text-sm font-medium transition hover:bg-accent",
              location.pathname === to ? "bg-accent text-foreground" : "text-foreground"
            )}
          >
            {Icon && <Icon className="h-4 w-4" />}
            <span className="truncate">{label}</span>
          </Link>
        ))}
      </div>
    </div>
  );
}
