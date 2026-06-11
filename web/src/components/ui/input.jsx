import React from "react";
import { cn } from "../../lib/utils.js";

export function Input({ className, ...props }) {
  return (
    <input
      className={cn("ui-input", className)}
      {...props}
    />
  );
}
