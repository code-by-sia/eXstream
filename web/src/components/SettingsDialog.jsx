import React from "react";
import { AdminUsersPanel } from "./AdminUsersPanel.jsx";
import { ChangePasswordForm } from "./ChangePasswordForm.jsx";
import { usePlayerStore } from "../store/usePlayerStore.js";
import { Dialog } from "./ui/dialog.jsx";

export function SettingsDialog({ open, onClose }) {
  const profile = usePlayerStore((s) => s.profile);
  const isAdmin = profile?.role === "ADMIN";

  return (
    <Dialog
      open={open}
      onClose={onClose}
      title="Settings"
      description={isAdmin ? "Your account and user administration." : "Manage your account."}
    >
      <div className="settings-body">
        <section className="settings-section">
          <p className="settings-section-title">Change password</p>
          <ChangePasswordForm />
        </section>
        {isAdmin ? (
          <section className="settings-section settings-section-divided">
            <AdminUsersPanel />
          </section>
        ) : null}
      </div>
    </Dialog>
  );
}
