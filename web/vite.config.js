import react from "@vitejs/plugin-react";
import { defineConfig } from "vite";

const apiTarget = process.env.VITE_API_TARGET || "http://traefik:80";

export default defineConfig({
  plugins: [react()],
  server: {
    host: "0.0.0.0",
    port: 7001,
    proxy: {
      "/auth": apiTarget,
      "/playlists": {
        target: apiTarget,
        bypass: (req) => ((req.headers.accept || "").includes("text/html") ? "/index.html" : undefined),
      },
      "/playlist": apiTarget,
      "/music": apiTarget,
      "/file": apiTarget,
      "/files": apiTarget,
    },
  },
});
