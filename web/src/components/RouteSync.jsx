import React from "react";
import { useEffect } from "react";
import { useLocation, useParams } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function RouteSync() {
  const { playlistId } = useParams();
  const location = useLocation();
  const token = usePlayerStore((s) => s.token);
  const setSelected = usePlayerStore((s) => s.setSelected);

  useEffect(() => {
    if (!playlistId || !token) return;
    request(`/playlists/${playlistId}`, { token })
      .then(setSelected)
      .catch(() => setSelected(undefined));
  }, [playlistId, token, setSelected]);

  useEffect(() => {
    if (location.pathname !== "/search" || !token) return;
    const q = new URLSearchParams(location.search).get("q") || "";
    request(`/music/search?q=${encodeURIComponent(q)}`, { token })
      .then((tracks) => setSelected({ id: "search", name: "Search", tracks }))
      .catch(() => setSelected({ id: "search", name: "Search", tracks: [] }));
  }, [location.pathname, location.search, token, setSelected]);

  useEffect(() => {
    if (playlistId || location.pathname === "/search") return;
    setSelected(undefined);
  }, [playlistId, location.pathname, setSelected]);

  return undefined;
}
