import "std/crypto.xi"

// Orchestrates the auth use-cases over the user repository and token service.
// Owns password comparison/hashing and token issuance so the HTTP layer only
// shuttles DTOs.
class AuthManager implements AuthService {
    deps { users: UserRepository, tokens: TokenService, identity: AuthIdentity }

    producer registerUser(username: String, password: String, profileName: String, email: String, avatar: String) -> AuthOutcome {
        if users.find(username).found { return outcome("exists") }
        let role = "USER"
        if not users.save(username, password, role, profileName, email, avatar) { return outcome("failed") }
        return authed(users.find(username), tokens.issue(username, role))
    }

    producer login(username: String, password: String) -> AuthOutcome {
        let user = users.find(username)
        if not user.found or user.passwordHash != crypto.sha256Hex(password) { return outcome("invalid-credentials") }
        return authed(user, tokens.issue(user.username, user.role))
    }

    producer changePassword(username: String, currentPassword: String, newPassword: String) -> AuthOutcome {
        let user = users.find(username)
        if not user.found { return outcome("not-found") }
        if user.passwordHash != crypto.sha256Hex(currentPassword) { return outcome("wrong-password") }
        users.save(user.username, newPassword, user.role, user.profileName, user.email, user.avatar)
        return okResult(user)
    }

    producer resetPassword(username: String, newPassword: String) -> AuthOutcome {
        let target = users.find(username)
        if not target.found { return outcome("not-found") }
        users.save(target.username, newPassword, target.role, target.profileName, target.email, target.avatar)
        return okResult(target)
    }

    producer createUser(username: String, password: String, role: String, profileName: String, email: String, avatar: String) -> AuthOutcome {
        if users.find(username).found { return outcome("exists") }
        let cleanedRole = identity.cleanRole(role)
        if not users.save(username, password, cleanedRole, profileName, email, avatar) { return outcome("failed") }
        return okResult(users.find(username))
    }

    producer listUsers() -> List<UserRecord> {
        return users.all()
    }

    producer findUser(username: String) -> UserRecord {
        return users.find(username)
    }

    mapper okResult(user: UserRecord) -> AuthOutcome => authed(user, "")
    mapper authed(user: UserRecord, token: String) -> AuthOutcome {
        return AuthOutcome { status: "ok", user: user, token: token }
    }
    mapper outcome(status: String) -> AuthOutcome {
        return AuthOutcome { status: status, user: noUser(), token: "" }
    }
    mapper noUser() -> UserRecord {
        return UserRecord { found: false, username: "", passwordHash: "", role: "", profileName: "", email: "", avatar: "" }
    }
}
