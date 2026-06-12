const THEME_COLORS = { light: "#f5f7f9", dark: "#0c0c0e" };

export function preferredDark() {
  const stored = localStorage.getItem("theme");
  if (stored) return stored === "dark";
  return window.matchMedia("(prefers-color-scheme: dark)").matches;
}

export function persistTheme(dark) {
  localStorage.setItem("theme", dark ? "dark" : "light");
}

export function applyTheme(dark) {
  document.documentElement.classList.toggle("dark", dark);
  document.querySelectorAll('meta[name="theme-color"][media]').forEach((meta) => meta.remove());
  let meta = document.querySelector('meta[name="theme-color"]');
  if (!meta) {
    meta = document.createElement("meta");
    meta.setAttribute("name", "theme-color");
    document.head.appendChild(meta);
  }
  meta.setAttribute("content", dark ? THEME_COLORS.dark : THEME_COLORS.light);
}
