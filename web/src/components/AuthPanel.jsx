import React from "react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { EmojiAvatarSelector } from "./EmojiAvatarSelector.jsx";
import { Input } from "./ui/input.jsx";

export function AuthPanel({ refresh }) {
  const [mode, setMode] = useState("login");
  const [error, setError] = useState("");
  const [busy, setBusy] = useState(false);
  const navigate = useNavigate();
  const setToken = usePlayerStore((s) => s.setToken);
  const setProfile = usePlayerStore((s) => s.setProfile);

  async function submit(event) {
    event.preventDefault();
    setBusy(true);
    setError("");
    try {
      const form = new FormData(event.currentTarget);
      const result = await request(`/auth/${mode}`, {
        method: "POST",
        body: JSON.stringify(Object.fromEntries(form)),
      });
      setToken(result.token);
      setProfile(result);
      await refresh();
      navigate("/");
    } catch (failure) {
      setError(failure.message || "Something went wrong. Please try again.");
      setBusy(false);
    }
  }

  return (
    <div className="auth-panel">
      <div className="auth-heading">
        <h1 className="auth-title">{mode === "login" ? "Welcome back" : "Create your account"}</h1>
        <p className="auth-subtitle">{mode === "login" ? "Sign in to your music library." : "Join eXstream and start listening."}</p>
      </div>

      <div className="auth-segments" role="tablist">
        <button type="button" role="tab" aria-selected={mode === "login"} className={mode === "login" ? "auth-segment auth-segment-active" : "auth-segment"} onClick={() => setMode("login")}>Sign in</button>
        <button type="button" role="tab" aria-selected={mode === "register"} className={mode === "register" ? "auth-segment auth-segment-active" : "auth-segment"} onClick={() => setMode("register")}>Register</button>
      </div>

      <form className="auth-form" onSubmit={(event) => submit(event).catch(() => setBusy(false))}>
        <Input name="username" placeholder="Username" autoComplete="username" required disabled={busy} />
        {mode === "register" && <Input name="profileName" placeholder="Profile name" autoComplete="name" required disabled={busy} />}
        {mode === "register" && <Input name="email" placeholder="Email" type="email" autoComplete="email" required disabled={busy} />}
        {mode === "register" && <EmojiAvatarSelector />}
        <Input name="password" placeholder="Password" type="password" autoComplete={mode === "register" ? "new-password" : "current-password"} required disabled={busy} />
        {error ? <p className="upload-message-error">{error}</p> : null}
        <Button type="submit" className="auth-submit" disabled={busy}>
          {busy ? "Please wait…" : mode === "login" ? "Sign in" : "Create account"}
        </Button>
      </form>
    </div>
  );
}
