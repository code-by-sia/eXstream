import React from "react";
import { cn } from "../../lib/utils.js";

const variants = {
  default: "ui-button-default",
  outline: "ui-button-outline",
  ghost: "ui-button-ghost",
  danger: "ui-button-danger",
};

export function Button({ className, variant, ...props }) {
  const buttonClassName = cn("ui-button", variants[variant || "default"], className);
  if (props.asChild) {
    const { asChild, children, ...rest } = props;
    return React.cloneElement(children, { className: cn(buttonClassName, children.props.className), ...rest });
  }
  return <button className={buttonClassName} {...props} />;
}
