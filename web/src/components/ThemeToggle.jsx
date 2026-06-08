import React from "react";
import { Moon, Sun } from "lucide-react";
import { Button } from "./ui/button.jsx";

export function ThemeToggle() {
  const [dark, setDark] = React.useState(() => localStorage.getItem("theme") === "dark");

  React.useEffect(() => {
    document.documentElement.classList.toggle("dark", dark);
    localStorage.setItem("theme", dark ? "dark" : "light");
  }, [dark]);

  return (
    <Button type="button" variant="outline" onClick={() => setDark((value) => !value)} aria-label="Toggle theme">
      {dark ? <Sun className="h-4 w-4" /> : <Moon className="h-4 w-4" />}
    </Button>
  );
}
