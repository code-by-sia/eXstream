const crypto = require("crypto");

function base64Url(buffer) {
  return Buffer.from(buffer)
    .toString("base64")
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=/g, "");
}

function decodePart(part) {
  const padded = part.replace(/-/g, "+").replace(/_/g, "/");
  return Buffer.from(padded, "base64").toString("utf8");
}

function sign(input, secret) {
  return base64Url(crypto.createHmac("sha256", secret).update(input).digest());
}

function verify(token, secret) {
  const parts = token.split(".");
  if (parts.length !== 3) return undefined;

  const input = `${parts[0]}.${parts[1]}`;
  if (sign(input, secret) !== parts[2]) return undefined;

  const payload = JSON.parse(decodePart(parts[1]));
  if (!payload.sub) return undefined;
  return { username: payload.sub, role: payload.role === "ADMIN" ? "ADMIN" : "USER" };
}

function issue(username, role, secret) {
  const header = base64Url(JSON.stringify({ alg: "HS256", typ: "JWT" }));
  const payload = base64Url(JSON.stringify({ sub: username, role }));
  const input = `${header}.${payload}`;
  return `${input}.${sign(input, secret)}`;
}

module.exports = { issue, verify };
