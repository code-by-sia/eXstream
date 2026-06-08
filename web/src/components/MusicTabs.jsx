import React from "react";
import { Button } from "./ui/button.jsx";

const tabs = ["Music", "Podcasts", "Live"];

export function MusicTabs() {
  return (
    <div className="inline-flex rounded-md bg-accent p-1">
      {tabs.map((tab, index) => (
        <Button key={tab} type="button" variant={index === 0 ? "outline" : "ghost"} className="min-h-8 border-transparent px-3">
          {tab}
        </Button>
      ))}
    </div>
  );
}
