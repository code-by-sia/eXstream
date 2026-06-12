import React from "react";
import { AuthPanel } from "../components/AuthPanel.jsx";

export function LoginPage({ refresh }) {
  return (
    <main className="login-shell">
      <section className="login-panel">
        <div className="login-brand">
          <span className="login-logo">X</span>
          <h1 className="login-title">eXstream</h1>
          <p className="login-subtitle">Sign in to your music library.</p>
        </div>
        <AuthPanel refresh={refresh} />
      </section>
    </main>
  );
}
