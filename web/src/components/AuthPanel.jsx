import React from "react";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { request } from "../api/client.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { Card } from "./ui/card.jsx";
import { Input } from "./ui/input.jsx";

export function AuthPanel({ refresh }) {
  const [mode, setMode] = useState("login");
  const navigate = useNavigate();
  const setToken = usePlayerStore((s) => s.setToken);

  async function submit(event) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    const result = await request(`/auth/${mode}`, {
      method: "POST",
      body: JSON.stringify(Object.fromEntries(form)),
    });
    setToken(result.token);
    await refresh();
    navigate("/");
  }

  return (
    <Card>
      <form className="grid gap-3" onSubmit={(event) => submit(event).catch(alert)}>
        <div className="grid grid-cols-2 gap-2">
          <Button type="button" variant={mode === "login" ? "default" : "outline"} onClick={() => setMode("login")}>Login</Button>
          <Button type="button" variant={mode === "register" ? "default" : "outline"} onClick={() => setMode("register")}>Register</Button>
        </div>
        <Input name="username" placeholder="Username" autoComplete="username" required />
        <Input name="password" placeholder="Password" type="password" autoComplete="current-password" required />
        {mode === "register" && (
          <select name="role" className="min-h-10 rounded-md border border-border px-3 text-sm">
            <option>USER</option>
            <option>ADMIN</option>
          </select>
        )}
        <Button type="submit">Continue</Button>
      </form>
    </Card>
  );
}
