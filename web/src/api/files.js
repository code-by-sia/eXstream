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

const coverCache = new Map();

async function hashContent(content) {
  if (globalThis.crypto?.subtle) {
    const buffer = await globalThis.crypto.subtle.digest("SHA-1", new TextEncoder().encode(content));
    return Array.from(new Uint8Array(buffer), (byte) => byte.toString(16).padStart(2, "0")).join("").slice(0, 20);
  }
  let hash = 0;
  for (const char of content) hash = (hash * 31 + char.charCodeAt(0)) >>> 0;
  return hash.toString(16);
}

// Caches an extracted album-art data URL in the file service and returns a
// short `/file/covers/<hash>` path to store on the track. Identical artwork is
// stored once (a 409 on create means it already exists).
export async function uploadCoverArt(token, dataUrl) {
  if (!dataUrl || !dataUrl.startsWith("data:")) return "";
  const path = `covers/${await hashContent(dataUrl)}`;
  const url = `/file/${path}`;
  try {
    await request(`/file/${path}`, { token, method: "POST", body: JSON.stringify({ content: dataUrl }) });
  } catch (error) {
    if (error.status !== 409) throw error;
  }
  coverCache.set(url, dataUrl);
  return url;
}

// Resolves a track cover to something usable as an <img src>: cached file-paths
// are fetched once and memoized; direct http/data URLs pass through.
export async function resolveCover(token, coverUrl) {
  if (!coverUrl) return "";
  if (!coverUrl.startsWith("/file/") && !coverUrl.startsWith("file/")) return coverUrl;
  const key = coverUrl.startsWith("/file/") ? coverUrl : `/file/${coverUrl}`;
  if (coverCache.has(key)) return coverCache.get(key);
  const file = await request(key, { token });
  coverCache.set(key, file.content);
  return file.content;
}
