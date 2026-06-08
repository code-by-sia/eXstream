export default {
  darkMode: "class",
  content: ["./index.html", "./src/**/*.jsx"],
  theme: {
    extend: {
      colors: {
        border: "hsl(var(--border))",
        background: "hsl(var(--background))",
        card: "hsl(var(--card))",
        foreground: "hsl(var(--foreground))",
        muted: "hsl(var(--muted))",
        primary: "hsl(var(--primary))",
        accent: "hsl(var(--accent))",
        focus: "hsl(var(--focus))",
      },
    },
  },
  plugins: [],
};
