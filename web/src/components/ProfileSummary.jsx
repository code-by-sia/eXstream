import React from "react";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Badge } from "./ui/badge.jsx";
import { Card, CardContent } from "./ui/card.jsx";

export function ProfileSummary() {
  const profile = usePlayerStore((s) => s.profile);
  const avatar = profile?.avatar || "🎧";
  const name = profile?.profileName || profile?.username || "Signed out";

  return (
    <Card className="profile-card">
      <CardContent className="profile-content">
        <span className="profile-avatar">{avatar}</span>
        <div className="profile-info">
          <p className="profile-name">{name}</p>
          <p className="profile-username">{profile?.username || "Signed out"}</p>
        </div>
        {profile?.role && <Badge className="profile-role-badge">{profile.role}</Badge>}
      </CardContent>
    </Card>
  );
}
