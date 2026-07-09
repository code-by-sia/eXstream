import "std/crypto.xi"
import "std/json.xi"
import "std/text.xi"
import "std/web.xi"

class AuthApi implements WebRequestHandler {
    deps { users: UserRepository, tokens: TokenService, identity: AuthIdentity }

    mapper getBaseUrl() -> String => "/auth"

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "POST", "/auth/register") {
        let body = web.body(req) as RegisterRequest
        if text.isEmpty(body.username) or text.isEmpty(body.password) {
            res.sendStatus(400, "username and password are required")
            return
        }
        if text.isEmpty(body.profileName) or text.isEmpty(body.email) {
            res.sendStatus(400, "profile name and email are required")
            return
        }

        let existing = users.find(body.username)
        if existing.found {
            res.sendStatus(409, "user already exists")
            return
        }

        let role = "USER"
        if not users.save(body.username, body.password, role, body.profileName, body.email, body.avatar) {
            res.sendStatus(500, "failed to save user")
            return
        }
        res.send(authResponse(tokens.issue(body.username, role), body.username, role, body.profileName, body.email, body.avatar))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "POST", "/auth/login") {
        let body = web.body(req) as LoginRequest
        let user = users.find(body.username)
        if not user.found or user.passwordHash != crypto.sha256Hex(body.password) {
            res.sendStatus(401, "invalid username or password")
            return
        }
        res.send(authResponse(tokens.issue(user.username, user.role), user.username, user.role, user.profileName, user.email, user.avatar))
    }

    // Authenticated: a signed-in user changes their own password after
    // confirming the current one.
    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "POST", "/auth/change-password") {
        let ctx = identity.context(req)
        if not ctx.ok {
            res.sendStatus(403, "missing identity headers")
            return
        }
        let body = web.body(req) as ChangePasswordRequest
        if text.isEmpty(body.newPassword) {
            res.sendStatus(400, "new password is required")
            return
        }
        let user = users.find(ctx.username)
        if not user.found {
            res.sendStatus(404, "user not found")
            return
        }
        if user.passwordHash != crypto.sha256Hex(body.currentPassword) {
            res.sendStatus(401, "current password is incorrect")
            return
        }
        users.save(user.username, body.newPassword, user.role, user.profileName, user.email, user.avatar)
        res.send(Message { ok: true, message: "password changed" })
    }

    // Admin only: reset another user's password without the old one.
    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "POST", "/auth/admin/reset-password") {
        if not requireAdmin(req, res) { return }
        let body = web.body(req) as AdminResetRequest
        if text.isEmpty(body.username) or text.isEmpty(body.newPassword) {
            res.sendStatus(400, "username and new password are required")
            return
        }
        let target = users.find(body.username)
        if not target.found {
            res.sendStatus(404, "user not found")
            return
        }
        users.save(target.username, body.newPassword, target.role, target.profileName, target.email, target.avatar)
        res.send(Message { ok: true, message: "password reset" })
    }

    // Admin only: list every user (no password hashes).
    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/auth/admin/users") {
        if not requireAdmin(req, res) { return }
        res.sendText(200, usersJson(users.all()))
    }

    // Admin only: create a user with a chosen role.
    action handle(req: HttpRequest, res: HttpResponse) where web.route(req,"POST", "/auth/admin/users")   {
        if not requireAdmin(req, res) { return }
        let body = web.body(req) as CreateUserRequest
        if text.isEmpty(body.username) or text.isEmpty(body.password) {
            res.sendStatus(400, "username and password are required")
            return
        }
        if text.isEmpty(body.profileName) or text.isEmpty(body.email) {
            res.sendStatus(400, "profile name and email are required")
            return
        }
        if users.find(body.username).found {
            res.sendStatus(409, "user already exists")
            return
        }
        let role = identity.cleanRole(body.role)
        if not users.save(body.username, body.password, role, body.profileName, body.email, body.avatar) {
            res.sendStatus(500, "failed to create user")
            return
        }
        res.send(profileResponse(body.username, role, users.find(body.username)))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/auth/verify") {
        let ctx = tokens.verify(identity.bearerToken(req.header("Authorization")))
        if not ctx.ok {
            res.sendStatus(401, "invalid token")
            return
        }
        let user = users.find(ctx.username)
        res.send(profileResponse(ctx.username, ctx.role, user))
    }

    action handle(req: HttpRequest, res: HttpResponse) where web.route(req, "GET", "/auth/profile") {
        let ctx = identity.context(req)
        if not ctx.ok {
            res.sendStatus(403, "missing identity headers")
            return
        }
        let user = users.find(ctx.username)
        res.send(profileResponse(ctx.username, ctx.role, user))
    }

    action handle(req: HttpRequest, res: HttpResponse) {
        res.sendStatus(404, "Not Found")
    }

    mapper authResponse(token: String, username: String, role: String, profileName: String, email: String, avatar: String) -> AuthResponse {
        return AuthResponse { token: token, username: username, role: role, profileName: profileName, email: email, avatar: avatar }
    }

    mapper profileResponse(username: String, role: String, user: UserRecord) -> ProfileResponse {
        if user.found {
            return ProfileResponse { username: user.username, role: role, profileName: user.profileName, email: user.email, avatar: user.avatar }
        }
        return ProfileResponse { username: username, role: role, profileName: username, email: "", avatar: "" }
    }

    predicate isAdmin(req: HttpRequest) {
        let ctx = identity.context(req)
        return ctx.ok and ctx.role == "ADMIN"
    }

    // Confirms the caller is an admin; writes 403 and returns false if not.
    producer requireAdmin(req: HttpRequest, res: HttpResponse) -> Bool {
        if isAdmin(req) { return true }
        res.sendStatus(403, "admin access required")
        return false
    }

    mapper usersJson(records: List<UserRecord>) -> String {
        let arr = json.array()
        for user in records {
            let obj = json.object()
            obj = json.set(obj, "username", json.str(user.username))
            obj = json.set(obj, "role", json.str(user.role))
            obj = json.set(obj, "profileName", json.str(user.profileName))
            obj = json.set(obj, "email", json.str(user.email))
            obj = json.set(obj, "avatar", json.str(user.avatar))
            arr = json.push(arr, obj)
        }
        let root = json.object()
        root = json.set(root, "users", arr)
        return json.stringify(root)
    }
}
