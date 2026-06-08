import React from "react";
import { TabsList, TabsTrigger } from "./ui/tabs.jsx";

const tabs = ["Music", "Podcasts", "Live"];

export function MusicTabs() {
  return (
    <TabsList>
      {tabs.map((tab, index) => (
        <TabsTrigger key={tab} active={index === 0}>{tab}</TabsTrigger>
      ))}
    </TabsList>
  );
}
