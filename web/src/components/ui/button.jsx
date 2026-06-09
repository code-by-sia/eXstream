import React from "react";
import { cva } from "class-variance-authority";
import { cn } from "../../lib/utils.js";

const variants = cva(
  "inline-flex min-h-10 items-center justify-center rounded-md border px-4 text-sm font-semibold transition",
  {
    variants: {
      variant: {
        default: "border-primary bg-primary text-white shadow-sm hover:brightness-95",
        outline: "border-border bg-card text-foreground shadow-sm hover:bg-accent",
        ghost: "border-transparent bg-transparent text-foreground hover:bg-accent",
      },
    },
    defaultVariants: { variant: "default" },
  }
);

export function Button({ className, variant, ...props }) {
  if (props.asChild) {
    const { asChild, children, ...rest } = props;
    return React.cloneElement(children, { className: cn(variants({ variant }), className, children.props.className), ...rest });
  }
  return <button className={cn(variants({ variant }), className)} {...props} />;
}
