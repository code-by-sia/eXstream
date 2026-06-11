import React from "react";
import { cn } from "../../lib/utils.js";

export function Select({ className, ...props }) {
  return (
    <select
      className={cn("ui-select", className)}
      {...props}
    />
  );
}
