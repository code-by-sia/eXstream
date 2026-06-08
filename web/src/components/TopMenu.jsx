import React from "react";
import { Link } from "react-router-dom";
import { ThemeToggle } from "./ThemeToggle.jsx";

const items = [["Music", "/"], ["File", "/admin/music"], ["Edit", "/"], ["View", "/search"], ["Account", "/login"]];

export function TopMenu() {
  return (
    <div className="flex h-10 items-center gap-1 border-b border-border bg-background px-2 shadow-sm lg:px-4">
      {items.map(([label, to], index) => (
        <Link key={label} to={to} className={index === 0 ? "rounded-sm px-3 py-1 text-sm font-bold" : "rounded-sm px-3 py-1 text-sm font-medium"}>
          {label}
        </Link>
      ))}
      <div className="ml-auto">
        <ThemeToggle />
      </div>
    </div>
  );
}
