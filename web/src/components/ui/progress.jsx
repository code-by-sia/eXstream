import React from "react";
import { cn } from "../../lib/utils.js";

export function Progress({ value = 0, className }) {
  const width = Math.max(0, Math.min(100, value));

  return (
    <div className={cn("h-2 overflow-hidden rounded-full bg-muted/30", className)}>
      <div className="h-full rounded-full bg-primary transition-all" style={{ width: `${width}%` }} />
    </div>
  );
}
