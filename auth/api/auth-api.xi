import "std/crypto.xi"
import "std/text.xi"
import "std/web.xi"
import "auth-types.xi"
import "../security-jwt.xi"

class AuthApi implements WebRequestHandler {
    deps { users: UserRepository }

    mapper getBaseUrl() -> String => "/auth"

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/auth/register" and req.method == "POST" {
        let body = req.parse(RegisterRequest)
        if text.isEmpty(body.username) or text.isEmpty(body.password) {
            res.sendStatus(400, "username and password are required")
            return
        }

        let existing = users.find(body.username)
        if existing.found {
            res.sendStatus(409, "user already exists")
            return
        }

        let role = cleanRole(body.role)
        if not users.save(body.username, body.password, role) {
            res.sendStatus(500, "failed to save user")
            return
        }
        res.send(AuthResponse { token: issueToken(body.username, role), username: body.username, role: role })
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/auth/login" and req.method == "POST" {
        let body = req.parse(LoginRequest)
        let user = users.find(body.username)
        if not user.found or user.passwordHash != crypto.sha256Hex(body.password) {
            res.sendStatus(401, "invalid username or password")
            return
        }
        res.send(AuthResponse { token: issueToken(user.username, user.role), username: user.username, role: user.role })
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/auth/reset-password" and req.method == "POST" {
        let body = req.parse(ResetPasswordRequest)
        let user = users.find(body.username)
        if not user.found {
            res.sendStatus(404, "user not found")
            return
        }
        if text.isEmpty(body.password) {
            res.sendStatus(400, "password is required")
            return
        }
        users.save(user.username, body.password, user.role)
        res.send(Message { ok: true, message: "password reset" })
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/auth/verify" and req.method == "GET" {
        let ctx = verifyToken(bearerToken(req.header("Authorization")))
        if not ctx.ok {
            res.sendStatus(401, "invalid token")
            return
        }
        res.send(ProfileResponse { username: ctx.username, role: ctx.role })
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/auth/profile" and req.method == "GET" {
        let ctx = protectedContext(req)
        if not ctx.ok {
            res.sendStatus(403, "missing identity headers")
            return
        }
        res.send(ProfileResponse { username: ctx.username, role: ctx.role })
    }

    action handle(req: HttpRequest, res: HttpResponse) {
        res.sendStatus(404, "Not Found")
    }
}
