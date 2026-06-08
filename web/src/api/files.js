import { request } from "./client.js";

function safeFileName(name) {
  return name.toLowerCase().replace(/[^a-z0-9._-]+/g, "-").replace(/^-+|-+$/g, "") || "track";
}

function readAsDataUrl(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = () => reject(reader.error);
    reader.readAsDataURL(file);
  });
}

export async function uploadMusicFile(token, file) {
  const content = await readAsDataUrl(file);
  const path = `music/${Date.now()}-${safeFileName(file.name)}`;
  const body = JSON.stringify({ content });

  try {
    await request(`/file/${path}`, { token, method: "POST", body });
  } catch (error) {
    if (!String(error.message).includes("already exists")) throw error;
    await request(`/file/${path}`, { token, method: "PUT", body });
  }
  return path;
}

export async function resolveTrackSource(token, source) {
  if (!source || source.startsWith("http") || source.startsWith("data:")) return source;
  const file = await request(`/file/${source}`, { token });
  return file.content;
}
