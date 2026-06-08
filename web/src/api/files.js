import { request } from "./client.js";

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
  const uploaded = await request("/file", { token, method: "POST", body: content, headers: { "Content-Type": "text/plain" } });

  return uploaded.url;
}

export async function resolveTrackSource(token, source) {
  if (!source || source.startsWith("http") || source.startsWith("data:")) return source;
  const file = await request(source.startsWith("/file/") ? source : `/file/${source}`, { token });
  return file.content;
}
