import React from "react";
import { Link } from "react-router-dom";
import { ThemeToggle } from "./ThemeToggle.jsx";
import { Menubar, MenubarItem } from "./ui/menubar.jsx";

const items = [["Music", "/"], ["File", "/admin/music"], ["Edit", "/"], ["View", "/search"], ["Account", "/login"]];

export function TopMenu() {
  return (
    <Menubar>
      {items.map(([label, to], index) => (
        <Link key={label} to={to}>
          <MenubarItem active={index === 0}>{label}</MenubarItem>
        </Link>
      ))}
      <div className="ml-auto">
        <ThemeToggle />
      </div>
    </Menubar>
  );
}
