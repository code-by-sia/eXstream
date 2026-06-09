import React from "react";

export function PageSection({ children, subtitle, title }) {
  return (
    <section className="grid gap-4">
      <div className="grid gap-1">
        <h2 className="text-2xl font-bold tracking-tight">{title}</h2>
        {subtitle ? <p className="text-sm text-muted">{subtitle}</p> : null}
      </div>
      {children}
    </section>
  );
}
