import React from "react";
import { useEffect, useState } from "react";
import { KeyRound, UserPlus } from "lucide-react";
import { adminCreateUser, adminListUsers, adminResetPassword } from "../api/account.js";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { EmojiAvatarSelector } from "./EmojiAvatarSelector.jsx";
import { Button } from "./ui/button.jsx";
import { Input } from "./ui/input.jsx";
import { Select } from "./ui/select.jsx";

export function AdminUsersPanel() {
  const token = usePlayerStore((s) => s.token);
  const [users, setUsers] = useState([]);
  const [error, setError] = useState("");
  const [resetFor, setResetFor] = useState("");

  async function refresh() {
    try {
      setUsers(await adminListUsers(token));
    } catch (failure) {
      setError(failure.message || "Could not load users");
    }
  }

  useEffect(() => { refresh().catch(() => {}); }, []);

  async function create(event) {
    event.preventDefault();
    const form = event.currentTarget;
    setError("");
    try {
      await adminCreateUser(token, Object.fromEntries(new FormData(form)));
      form.reset();
      await refresh();
    } catch (failure) {
      setError(failure.message || "Could not create user");
    }
  }

  async function reset(event, username) {
    event.preventDefault();
    const form = event.currentTarget;
    setError("");
    try {
      await adminResetPassword(token, username, new FormData(form).get("newPassword"));
      setResetFor("");
    } catch (failure) {
      setError(failure.message || "Could not reset password");
    }
  }

  return (
    <div className="admin-users">
      <form className="settings-form" onSubmit={(event) => create(event).catch(() => {})}>
        <p className="settings-section-title">Create user</p>
        <Input name="username" placeholder="Username" autoComplete="off" required />
        <Input name="profileName" placeholder="Profile name" required />
        <Input name="email" type="email" placeholder="Email" required />
        <Input name="password" type="password" placeholder="Password" autoComplete="new-password" required />
        <Select name="role" defaultValue="USER">
          <option value="USER">User</option>
          <option value="ADMIN">Admin</option>
        </Select>
        <EmojiAvatarSelector />
        <Button type="submit"><UserPlus className="button-icon-gap" /> Create user</Button>
      </form>

      <p className="settings-section-title">All users</p>
      <ul className="admin-users-list">
        {users.map((user) => (
          <li key={user.username} className="admin-users-row">
            <div className="admin-users-main">
              <span className="admin-users-avatar">{user.avatar || "🎧"}</span>
              <span className="admin-users-meta">
                <span className="admin-users-name">{user.profileName || user.username}</span>
                <span className="admin-users-username">{user.username}</span>
              </span>
              <span className="ui-badge">{user.role}</span>
              <button
                type="button"
                className="track-action-button"
                title="Reset password"
                aria-label={`Reset ${user.username} password`}
                onClick={() => setResetFor(resetFor === user.username ? "" : user.username)}
              >
                <KeyRound className="icon-xs" />
              </button>
            </div>
            {resetFor === user.username ? (
              <form className="admin-users-reset" onSubmit={(event) => reset(event, user.username).catch(() => {})}>
                <Input name="newPassword" type="password" placeholder="New password" autoComplete="new-password" required />
                <Button type="submit">Reset</Button>
              </form>
            ) : null}
          </li>
        ))}
      </ul>
      {error ? <p className="upload-message-error">{error}</p> : null}
    </div>
  );
}
