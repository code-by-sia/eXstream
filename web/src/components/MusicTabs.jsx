import React from "react";
import { Button } from "./ui/button.jsx";

const tabs = ["Music", "Podcasts", "Live"];

export function MusicTabs() {
  return (
    <div className="flex gap-2">
      {tabs.map((tab, index) => (
        <Button key={tab} type="button" variant={index === 0 ? "default" : "outline"}>
          {tab}
        </Button>
      ))}
    </div>
  );
}
