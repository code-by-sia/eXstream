import React from "react";
import { cn } from "../../lib/utils.js";

export function Card({ className, ...props }) {
  return <section className={cn("rounded-lg border border-border bg-card p-4", className)} {...props} />;
}
