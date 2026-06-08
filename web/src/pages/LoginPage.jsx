import React from "react";
import { AuthPanel } from "../components/AuthPanel.jsx";

export function LoginPage({ refresh }) {
  return (
    <main className="grid min-h-screen place-items-center bg-background p-6">
      <section className="grid w-full max-w-md gap-5">
        <div className="grid justify-items-center gap-2 text-center">
          <span className="grid h-14 w-14 place-items-center rounded-md bg-foreground text-xl font-bold text-white">X</span>
          <h1 className="text-3xl font-bold">eXstream</h1>
          <p className="text-sm text-muted">Sign in to your music library.</p>
        </div>
        <AuthPanel refresh={refresh} />
      </section>
    </main>
  );
}
