import React from "react";
import { cn } from "../../lib/utils.js";

export function Input({ className, ...props }) {
  return (
    <input
      className={cn("min-h-10 w-full rounded-md border border-border bg-card px-3 text-sm outline-focus", className)}
      {...props}
    />
  );
}
