// Every backend endpoint is served under the /api gateway prefix. The prefix
// is added here in one place; the ingress strips it before forwarding to the
// services, so service-side routes stay unprefixed.
const API_BASE = "/api";

function apiUrl(path) {
  if (/^https?:\/\//.test(path)) return path;
  const rooted = path.startsWith("/") ? path : `/${path}`;
  return rooted.startsWith(`${API_BASE}/`) ? rooted : `${API_BASE}${rooted}`;
}

export async function request(path, { token, ...options } = {}) {
  const response = await fetch(apiUrl(path), {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(options.headers || {}),
    },
  });

  const text = await response.text();
  if (!response.ok) {
    const error = new Error(text || response.statusText);
    error.status = response.status;
    throw error;
  }
  return text ? JSON.parse(text) : undefined;
}
