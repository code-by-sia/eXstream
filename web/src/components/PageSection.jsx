import React from "react";

export function PageSection({ children, subtitle, title }) {
  return (
    <section className="page-section">
      <div className="page-section-heading">
        <h2 className="page-section-title">{title}</h2>
        {subtitle ? <p className="page-section-subtitle">{subtitle}</p> : null}
      </div>
      {children}
    </section>
  );
}
