import React from "react";
import { cn } from "../../lib/utils.js";

export function Separator({ className, ...props }) {
  return <div className={cn("ui-separator", className)} role="separator" {...props} />;
}
