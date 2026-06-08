const assert = require("node:assert/strict");
const test = require("node:test");
const { issue, verify } = require("../token");

test("verifies a valid admin token", () => {
  const token = issue("admin", "ADMIN", "test-secret");
  const identity = verify(token, "test-secret");

  assert.deepEqual(identity, { username: "admin", role: "ADMIN" });
});

test("normalizes non-admin roles to user", () => {
  const token = issue("test", "other", "test-secret");
  const identity = verify(token, "test-secret");

  assert.deepEqual(identity, { username: "test", role: "USER" });
});

test("rejects tampered tokens", () => {
  const token = issue("test", "USER", "test-secret");

  assert.equal(verify(`${token}x`, "test-secret"), undefined);
});
