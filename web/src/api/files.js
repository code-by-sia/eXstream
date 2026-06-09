import { request } from "./client.js";
import { toneToDataUrl } from "./tone-audio.js";

function safeFileName(name) {
  return name.toLowerCase().replace(/[^a-z0-9._-]+/g, "-").replace(/^-+|-+$/g, "") || "track";
}

function uniqueMusicPath(file) {
  const id = globalThis.crypto?.randomUUID
    ? globalThis.crypto.randomUUID()
    : `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  return `music/${id}-${safeFileName(file.name)}`;
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
  try {
    const uploaded = await request("/file", {
      token,
      method: "POST",
      body: content,
      headers: { "Content-Type": "text/plain" },
    });
    return uploaded.url;
  } catch (error) {
    if (error.status !== 404) throw error;
  }

  const path = uniqueMusicPath(file);
  await request(`/file/${path}`, {
    token,
    method: "POST",
    body: JSON.stringify({ content }),
  });
  return `/file/${path}`;
}

export async function resolveTrackSource(token, source) {
  if (!source || source.startsWith("http") || source.startsWith("data:")) return source;
  if (source.startsWith("tone:")) return toneToDataUrl(source);
  const file = await request(source.startsWith("/file/") ? source : `/file/${source}`, { token });
  return file.content;
}
