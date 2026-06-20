import React from "react";
import { useState } from "react";
import { changePassword } from "../api/account.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";

export function ChangePasswordForm() {
  const token = usePlayerStore((s) => s.token);
  const [status, setStatus] = useState({ tone: "", message: "" });
  const [busy, setBusy] = useState(false);

  async function submit(event) {
    event.preventDefault();
    const formElement = event.currentTarget;
    const form = new FormData(formElement);
    const next = form.get("newPassword");
    if (next !== form.get("confirmPassword")) {
      setStatus({ tone: "error", message: "New passwords do not match." });
      return;
    }
    setBusy(true);
    setStatus({ tone: "", message: "" });
    try {
      await changePassword(token, form.get("currentPassword"), next);
      formElement.reset();
      setStatus({ tone: "ok", message: "Password changed." });
    } catch (error) {
      setStatus({ tone: "error", message: error.message || "Could not change password." });
    }
    setBusy(false);
  }

  return (
    <form className="settings-form" onSubmit={submit}>
      <Input name="currentPassword" type="password" placeholder="Current password" autoComplete="current-password" required disabled={busy} />
      <Input name="newPassword" type="password" placeholder="New password" autoComplete="new-password" required disabled={busy} />
      <Input name="confirmPassword" type="password" placeholder="Confirm new password" autoComplete="new-password" required disabled={busy} />
      <div className="settings-form-footer">
        {status.message ? <p className={status.tone === "error" ? "upload-message-error" : "settings-ok"}>{status.message}</p> : <span />}
        <Button type="submit" disabled={busy}>{busy ? "Saving…" : "Change password"}</Button>
      </div>
    </form>
  );
}
