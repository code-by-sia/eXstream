import React from "react";
import { cn } from "../../lib/utils.js";

export function Card({ className, ...props }) {
  return <section className={cn("rounded-lg border border-border bg-card shadow-sm", className)} {...props} />;
}

export function CardHeader({ className, ...props }) {
  return <div className={cn("grid gap-1.5 p-4", className)} {...props} />;
}

export function CardTitle({ className, ...props }) {
  return <h2 className={cn("text-lg font-semibold leading-none", className)} {...props} />;
}

export function CardDescription({ className, ...props }) {
  return <p className={cn("text-sm text-muted", className)} {...props} />;
}

export function CardContent({ className, ...props }) {
  return <div className={cn("p-4 pt-0", className)} {...props} />;
}

export function CardFooter({ className, ...props }) {
  return <div className={cn("flex items-center p-4 pt-0", className)} {...props} />;
}
