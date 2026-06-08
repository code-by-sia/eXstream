import React from "react";
import { cn } from "../../lib/utils.js";

export function TabsList({ className, ...props }) {
  return <div className={cn("inline-flex rounded-md bg-accent p-1", className)} {...props} />;
}

export function TabsTrigger({ className, active, ...props }) {
  return (
    <button
      className={cn("min-h-8 rounded-md border border-transparent px-3 text-sm font-medium", active && "bg-card shadow-sm", className)}
      type="button"
      {...props}
    />
  );
}
