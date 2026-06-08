import React from "react";
import { cn } from "../../lib/utils.js";

export function Separator({ className, ...props }) {
  return <div className={cn("h-px w-full bg-border", className)} role="separator" {...props} />;
}
