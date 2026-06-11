import React from "react";
import { cn } from "../../lib/utils.js";

export function TabsList({ className, ...props }) {
  return <div className={cn("ui-tabs-list", className)} {...props} />;
}

export function TabsTrigger({ className, active, ...props }) {
  return (
    <button
      className={cn("ui-tabs-trigger", active && "ui-tabs-trigger-active", className)}
      type="button"
      {...props}
    />
  );
}
