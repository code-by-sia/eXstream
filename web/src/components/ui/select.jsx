import React from "react";
import { cn } from "../../lib/utils.js";

export function Select({ className, ...props }) {
  return (
    <select
      className={cn("min-h-10 w-full rounded-md border border-border bg-card px-3 text-sm outline-focus", className)}
      {...props}
    />
  );
}
