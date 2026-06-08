import React from "react";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Badge } from "./ui/badge.jsx";
import { Card, CardContent } from "./ui/card.jsx";

export function ProfileSummary() {
  const profile = usePlayerStore((s) => s.profile);
  const avatar = profile?.avatar || "🎧";
  const name = profile?.profileName || profile?.username || "Signed out";

  return (
    <Card className="bg-background">
      <CardContent className="flex min-w-0 items-center gap-3 p-3">
        <span className="grid h-10 w-10 shrink-0 place-items-center rounded-md bg-accent text-xl">{avatar}</span>
        <div className="min-w-0">
          <p className="truncate text-sm font-semibold">{name}</p>
          <p className="truncate text-xs text-muted">{profile?.username || "Signed out"}</p>
        </div>
        {profile?.role && <Badge className="ml-auto">{profile.role}</Badge>}
      </CardContent>
    </Card>
  );
}
