import React from "react";
import { cn } from "../../lib/utils.js";

export function Badge({ className, ...props }) {
  return (
    <span
      className={cn("inline-flex min-h-6 items-center rounded-md border border-border bg-accent px-2 text-xs font-medium", className)}
      {...props}
    />
  );
}
