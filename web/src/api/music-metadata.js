const textFrames = { TIT2: "title", TPE1: "artist" };

export async function readMusicMetadata(file) {
  const fallback = metadataFromFileName(file?.name || "");
  if (!file?.slice) return fallback;

  const bytes = new Uint8Array(await file.slice(0, 512 * 1024).arrayBuffer());
  return { ...fallback, ...nonEmpty(parseId3Metadata(bytes)) };
}

export function metadataFromFileName(name) {
  const base = (name.split(/[\\/]/).pop() || "")
    .replace(/\.[^.]+$/, "")
    .replace(/[_]+/g, " ")
    .replace(/\s+/g, " ")
    .trim();
  const parts = base.split(/\s+-\s+/);

  if (parts.length > 1) {
    return { artist: parts[0], title: parts.slice(1).join(" - ") };
  }
  return { artist: "", title: base || "Untitled track" };
}

export function parseId3Metadata(bytes) {
  if (ascii(bytes, 0, 3) !== "ID3") return {};

  const major = bytes[3];
  const tagEnd = Math.min(10 + syncSafe(bytes, 6), bytes.length);
  let offset = frameStart(bytes, major);
  const tags = {};

  while (offset + 10 <= tagEnd) {
    const id = ascii(bytes, offset, 4);
    if (!/^[A-Z0-9]{4}$/.test(id)) break;

    const size = major === 4 ? syncSafe(bytes, offset + 4) : uint32(bytes, offset + 4);
    const value = decodeTextFrame(bytes.subarray(offset + 10, offset + 10 + size));
    if (textFrames[id] && value) tags[textFrames[id]] = value;
    offset += 10 + size;
  }

  return tags;
}

function ascii(bytes, start, length) {
  return Array.from(bytes.subarray(start, start + length), (byte) => String.fromCharCode(byte)).join("");
}

function decodeTextFrame(bytes) {
  if (!bytes.length) return "";
  const encoding = bytes[0];
  const body = bytes.subarray(1);
  const label = encoding === 3 ? "utf-8" : encoding === 0 ? "iso-8859-1" : "utf-16";
  return new TextDecoder(label).decode(body).replace(/\0/g, "").trim();
}

function frameStart(bytes, major) {
  if ((bytes[5] & 0x40) === 0) return 10;
  return major === 4 ? 14 + syncSafe(bytes, 10) : 14 + uint32(bytes, 10);
}

function nonEmpty(values) {
  return Object.fromEntries(Object.entries(values).filter((entry) => entry[1]));
}

function syncSafe(bytes, offset) {
  return (bytes[offset] << 21) | (bytes[offset + 1] << 14) | (bytes[offset + 2] << 7) | bytes[offset + 3];
}

function uint32(bytes, offset) {
  return (bytes[offset] << 24) | (bytes[offset + 1] << 16) | (bytes[offset + 2] << 8) | bytes[offset + 3];
}
