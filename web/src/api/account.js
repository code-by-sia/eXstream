import { request } from "./client.js";

// Authenticated: the signed-in user changes their own password.
export function changePassword(token, currentPassword, newPassword) {
  return request("/auth/change-password", {
    token,
    method: "POST",
    body: JSON.stringify({ currentPassword, newPassword }),
  });
}

// Admin: list every user (no password hashes).
export async function adminListUsers(token) {
  const result = await request("/auth/admin/users", { token });
  return result.users || [];
}

// Admin: create a user with a chosen role.
export function adminCreateUser(token, user) {
  return request("/auth/admin/users", { token, method: "POST", body: JSON.stringify(user) });
}

// Admin: reset another user's password.
export function adminResetPassword(token, username, newPassword) {
  return request("/auth/admin/reset-password", {
    token,
    method: "POST",
    body: JSON.stringify({ username, newPassword }),
  });
}
