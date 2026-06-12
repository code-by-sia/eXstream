import React from "react";
import { createPortal } from "react-dom";
import { X } from "lucide-react";

export function Dialog({ open, onClose, title, description, children }) {
  React.useEffect(() => {
    if (!open) return undefined;
    function onKeyDown(event) {
      if (event.key === "Escape") onClose();
    }
    document.addEventListener("keydown", onKeyDown);
    return () => document.removeEventListener("keydown", onKeyDown);
  }, [open, onClose]);

  if (!open) return null;
  return createPortal(
    <div className="ui-dialog-overlay" role="presentation" onClick={onClose}>
      <section
        role="dialog"
        aria-modal="true"
        aria-label={title}
        className="ui-dialog"
        onClick={(event) => event.stopPropagation()}
      >
        <header className="ui-dialog-header">
          <div className="ui-dialog-heading">
            <h2 className="ui-dialog-title">{title}</h2>
            {description ? <p className="ui-dialog-description">{description}</p> : null}
          </div>
          <button type="button" className="ui-dialog-close" onClick={onClose} aria-label="Close dialog">
            <X className="icon-sm" />
          </button>
        </header>
        <div className="ui-dialog-body">{children}</div>
      </section>
    </div>,
    document.body
  );
}
