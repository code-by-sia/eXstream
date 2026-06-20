import React from "react";
import { Headphones, ListMusic, Radio } from "lucide-react";
import { AuthPanel } from "../components/AuthPanel.jsx";
import { LoginIllustration } from "../components/LoginIllustration.jsx";

export function LoginPage({ refresh }) {
  return (
    <main className="auth-shell">
      <section className="auth-brand">
        <div className="auth-brand-head">
          <img src="/icons/icon.svg" alt="" className="auth-brand-logo" />
          <span className="auth-brand-name">eXstream</span>
        </div>
        <LoginIllustration />
        <div className="auth-brand-copy">
          <h2 className="auth-brand-title">Your sound, everywhere.</h2>
          <p className="auth-brand-text">Stream your library, build playlists, and pick up right where you left off.</p>
          <ul className="auth-brand-features">
            <li><Headphones className="icon-sm" /> Your whole library, one tap away</li>
            <li><ListMusic className="icon-sm" /> Playlists that move with you</li>
            <li><Radio className="icon-sm" /> Stations built from your taste</li>
          </ul>
        </div>
      </section>

      <section className="auth-form-panel">
        <div className="auth-form-inner">
          <div className="auth-compact-brand">
            <img src="/icons/icon.svg" alt="" className="auth-brand-logo" />
            <span className="auth-brand-name">eXstream</span>
          </div>
          <AuthPanel refresh={refresh} />
        </div>
      </section>
    </main>
  );
}
