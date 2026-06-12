import React from "react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { Card, CardContent } from "./ui/card.jsx";
import { EmojiAvatarSelector } from "./EmojiAvatarSelector.jsx";
import { Input } from "./ui/input.jsx";

export function AuthPanel({ refresh }) {
  const [mode, setMode] = useState("login");
  const navigate = useNavigate();
  const setToken = usePlayerStore((s) => s.setToken);
  const setProfile = usePlayerStore((s) => s.setProfile);

  async function submit(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const result = await request(`/auth/${mode}`, {
      method: "POST",
      body: JSON.stringify(Object.fromEntries(form)),
    });
    setToken(result.token);
    setProfile(result);
    await refresh();
    navigate("/");
  }

  return (
    <Card>
      <CardContent className="auth-card-content">
        <form className="auth-form" onSubmit={(event) => submit(event).catch(alert)}>
          <div className="auth-mode-grid">
            <Button type="button" variant={mode === "login" ? "default" : "outline"} onClick={() => setMode("login")}>Login</Button>
            <Button type="button" variant={mode === "register" ? "default" : "outline"} onClick={() => setMode("register")}>Register</Button>
          </div>
          <Input name="username" placeholder="Username" autoComplete="username" required />
          {mode === "register" && <Input name="profileName" placeholder="Profile Name" autoComplete="name" required />}
          {mode === "register" && <Input name="email" placeholder="Email" type="email" autoComplete="email" required />}
          {mode === "register" && <EmojiAvatarSelector />}
          <Input name="password" placeholder="Password" type="password" autoComplete={mode === "register" ? "new-password" : "current-password"} required />
          <Button type="submit">Continue</Button>
        </form>
      </CardContent>
    </Card>
  );
}
