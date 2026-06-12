import React from "react";
import { Moon, Sun } from "lucide-react";
import { applyTheme, persistTheme, preferredDark } from "../lib/theme.js";

export function ThemeToggle() {
  const [dark, setDark] = React.useState(preferredDark);

  React.useEffect(() => {
    applyTheme(dark);
  }, [dark]);

  function toggle() {
    setDark((value) => {
      persistTheme(!value);
      return !value;
    });
  }

  return (
    <button type="button" className="sidebar-icon-button" onClick={toggle} aria-label="Toggle theme">
      {dark ? <Sun className="icon-sm" /> : <Moon className="icon-sm" />}
    </button>
  );
}
