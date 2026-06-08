import React from "react";
import { usePlayerStore } from "../store/usePlayerStore.js";

export function ProfileSummary() {
  const profile = usePlayerStore((s) => s.profile);
  const avatar = profile?.avatar || "🎧";
  const name = profile?.profileName || profile?.username || "Signed out";

  return (
    <div className="flex min-w-0 items-center gap-3 rounded-md border border-border bg-background p-3">
      <span className="grid h-10 w-10 shrink-0 place-items-center rounded-md bg-accent text-xl">{avatar}</span>
      <div className="min-w-0">
        <p className="truncate text-sm font-semibold">{name}</p>
        <p className="truncate text-xs text-muted">{profile ? `${profile.username} · ${profile.role}` : "Signed out"}</p>
      </div>
    </div>
  );
}
