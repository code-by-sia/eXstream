import assert from "node:assert/strict";
import test from "node:test";
import { request } from "../api/client.js";

test("sends bearer tokens and parses json responses", async () => {
  globalThis.fetch = async (path, options) => {
    assert.equal(path, "/auth/profile");
    assert.equal(options.headers.Authorization, "Bearer abc");
    return new Response(JSON.stringify({ username: "test" }), { status: 200 });
  };

  const result = await request("/auth/profile", { token: "abc" });

  assert.deepEqual(result, { username: "test" });
});

test("throws response text for failed requests", async () => {
  globalThis.fetch = async () => new Response("missing identity headers", { status: 403 });

  await assert.rejects(() => request("/playlists"), /missing identity headers/);
});

test("omits authorization when token is empty", async () => {
  globalThis.fetch = async (path, options) => {
    assert.equal(path, "/auth/login");
    assert.equal(options.headers.Authorization, undefined);
    return new Response(JSON.stringify({ token: "ok" }), { status: 200 });
  };

  const result = await request("/auth/login", { method: "POST", body: "{}" });

  assert.deepEqual(result, { token: "ok" });
});
