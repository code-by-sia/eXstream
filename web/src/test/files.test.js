import assert from "node:assert/strict";
import test from "node:test";
import { uploadMusicFile } from "../api/files.js";

class FileReaderStub {
  readAsDataURL() {
    this.result = "data:audio/mpeg;base64,abc";
    this.onload();
  }
}

test("falls back to legacy file upload route when gateway returns 404", async () => {
  const calls = [];
  const cryptoDescriptor = Object.getOwnPropertyDescriptor(globalThis, "crypto");
  globalThis.FileReader = FileReaderStub;
  Object.defineProperty(globalThis, "crypto", {
    value: { randomUUID: () => "song-id" },
    configurable: true,
  });
  try {
    globalThis.fetch = async (path, options) => {
      calls.push({ path, options });
      if (path === "/file") return new Response("not found", { status: 404 });
      return new Response(JSON.stringify({ ok: true }), { status: 200 });
    };

    const url = await uploadMusicFile("token", { name: "My Song.mp3" });

    assert.equal(url, "/file/music/song-id-my-song.mp3");
    assert.deepEqual(calls.map((call) => call.path), ["/file", "/file/music/song-id-my-song.mp3"]);
    assert.equal(calls[1].options.headers.Authorization, "Bearer token");
  } finally {
    Object.defineProperty(globalThis, "crypto", cryptoDescriptor);
  }
});
