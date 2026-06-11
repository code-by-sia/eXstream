import React from "react";
import { cn } from "../../lib/utils.js";

export function Progress({ value = 0, className }) {
  const width = Math.max(0, Math.min(100, value));

  return (
    <div className={cn("ui-progress", className)}>
      <div className="ui-progress-bar" style={{ width: `${width}%` }} />
    </div>
  );
}
