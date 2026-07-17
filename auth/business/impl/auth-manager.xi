import "std/crypto.xi"

// Orchestrates the auth use-cases over the user repository and token service.
// Owns password comparison/hashing, token issuance, and the
// UserRow <-> UserRecord conversion so the HTTP layer only shuttles DTOs.
class AuthManager implements AuthService {
    deps { users: UserRepository, tokens: TokenService, identity: AuthIdentity }

    producer registerUser(username: String, password: String, profileName: String, email: String, avatar: String) -> AuthOutcome {
        if let existing = users.find(username) { return outcome("exists") }
        let role = "USER"
        users.save(UserRow { id: username, password_hash: crypto.sha256Hex(password), role: role, profile_name: profileName, email: email, avatar: avatar })
        return authed(recordOf(username), tokens.issue(username, role))
    }

    producer login(username: String, password: String) -> AuthOutcome {
        if let row = users.find(username) {
            if row.password_hash != crypto.sha256Hex(password) { return outcome("invalid-credentials") }
            return authed(recordFrom(row), tokens.issue(row.id, row.role))
        }
        return outcome("invalid-credentials")
    }

    producer changePassword(username: String, currentPassword: String, newPassword: String) -> AuthOutcome {
        if let row = users.find(username) {
            if row.password_hash != crypto.sha256Hex(currentPassword) { return outcome("wrong-password") }
            users.save(UserRow { id: row.id, password_hash: crypto.sha256Hex(newPassword), role: row.role, profile_name: row.profile_name, email: row.email, avatar: row.avatar })
            return okResult(recordFrom(row))
        }
        return outcome("not-found")
    }

    producer resetPassword(username: String, newPassword: String) -> AuthOutcome {
        if let row = users.find(username) {
            users.save(UserRow { id: row.id, password_hash: crypto.sha256Hex(newPassword), role: row.role, profile_name: row.profile_name, email: row.email, avatar: row.avatar })
            return okResult(recordFrom(row))
        }
        return outcome("not-found")
    }

    producer createUser(username: String, password: String, role: String, profileName: String, email: String, avatar: String) -> AuthOutcome {
        if let existing = users.find(username) { return outcome("exists") }
        let cleanedRole = identity.cleanRole(role)
        users.save(UserRow { id: username, password_hash: crypto.sha256Hex(password), role: cleanedRole, profile_name: profileName, email: email, avatar: avatar })
        return okResult(recordOf(username))
    }

    producer listUsers() -> List<UserRecord> {
        let out = empty List<UserRecord>
        for row in users.all() { out.push(recordFrom(row)) }
        return out
    }

    producer findUser(username: String) -> UserRecord => recordOf(username)

    mapper recordOf(username: String) -> UserRecord {
        if let row = users.find(username) { return recordFrom(row) }
        return noUser()
    }

    mapper recordFrom(row: UserRow) -> UserRecord {
        return UserRecord { found: true, username: row.id, passwordHash: row.password_hash, role: row.role, profileName: row.profile_name, email: row.email, avatar: row.avatar }
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
