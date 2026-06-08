const http = require("http");
const { verify } = require("./token");

const secret = process.env.JWT_SECRET || "dev-secret";

function tokenFrom(req) {
  const header = req.headers.authorization || "";
  return header.startsWith("Bearer ") ? header.slice(7) : "";
}

http
  .createServer((req, res) => {
    try {
      const identity = verify(tokenFrom(req), secret);
      if (!identity) {
        res.writeHead(401);
        res.end("invalid token");
        return;
      }

      res.writeHead(204, {
        "X-Username": identity.username,
        "X-Role": identity.role,
      });
      res.end();
    } catch {
      res.writeHead(401);
      res.end("invalid token");
    }
  })
  .listen(3000, "0.0.0.0");
