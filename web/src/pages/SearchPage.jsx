import React from "react";
import { useLocation } from "react-router-dom";
import { PageSection } from "../components/PageSection.jsx";
import { TrackList } from "../components/TrackList.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { LibraryPageFrame } from "./LibraryPageFrame.jsx";

export function SearchPage({ refresh }) {
  const location = useLocation();
  const selected = usePlayerStore((s) => s.selected);
  const q = new URLSearchParams(location.search).get("q") || "";
  const title = q ? `Search: ${q}` : "Search";
  const tracks = selected?.id === "search" ? selected.tracks : [];

  return (
    <LibraryPageFrame refresh={refresh} title={title}>
      <PageSection title="Results" subtitle={q ? "Tracks matching your search." : "No search submitted yet."}>
        <TrackList tracks={tracks} />
      </PageSection>
    </LibraryPageFrame>
  );
}
