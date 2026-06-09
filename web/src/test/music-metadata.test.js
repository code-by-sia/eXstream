import assert from "node:assert/strict";
import test from "node:test";
import { metadataFromFileName, parseId3Metadata } from "../api/music-metadata.js";

test("uses artist and title from file names", () => {
  assert.deepEqual(metadataFromFileName("Nina Netcode - Async Awakenings.mp3"), {
    artist: "Nina Netcode",
    title: "Async Awakenings",
  });
});

test("parses id3 title and artist text frames", () => {
  const bytes = tag([frame("TIT2", "Browser Song"), frame("TPE1", "Metadata Artist")]);

  assert.deepEqual(parseId3Metadata(bytes), {
    artist: "Metadata Artist",
    title: "Browser Song",
  });
});

test("parses id3 album art frames", () => {
  const png = bytes([137, 80, 78, 71]);
  const body = bytes([3, ...ascii("image/png"), 0, 3, 0, ...png]);
  const parsed = parseId3Metadata(tag([binaryFrame("APIC", body)]));

  assert.equal(parsed.coverUrl, "data:image/png;base64,iVBORw==");
});

function frame(id, text) {
  const body = bytes([3, ...new TextEncoder().encode(text)]);
  return binaryFrame(id, body);
}

function binaryFrame(id, body) {
  return bytes([...ascii(id), ...uint32(body.length), 0, 0, ...body]);
}

function tag(frames) {
  const body = bytes(frames.flatMap((part) => Array.from(part)));
  return bytes([...ascii("ID3"), 3, 0, 0, ...syncSafe(body.length), ...body]);
}

function ascii(text) {
  return Array.from(text, (char) => char.charCodeAt(0));
}

function bytes(values) {
  return new Uint8Array(values);
}

function syncSafe(value) {
  return [(value >> 21) & 0x7f, (value >> 14) & 0x7f, (value >> 7) & 0x7f, value & 0x7f];
}

function uint32(value) {
  return [(value >> 24) & 0xff, (value >> 16) & 0xff, (value >> 8) & 0xff, value & 0xff];
}
