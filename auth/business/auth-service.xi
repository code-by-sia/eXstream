// Application/use-case layer for authentication and user administration. The
// HTTP layer depends on this seam instead of UserRepository/TokenService, so
// credential checking, hashing, and token issuance live in one place.
// Implemented by AuthManager.
//
// `status` values the caller maps to HTTP: "ok" | "invalid-credentials" |
// "exists" | "not-found" | "wrong-password" | "failed". On "ok", `user` is the
// affected record and `token` is set for register/login (empty otherwise).
type AuthOutcome = { status: String, user: UserRecord, token: String }

interface AuthService {
    producer registerUser(username: String, password: String, profileName: String, email: String, avatar: String) -> AuthOutcome
    producer login(username: String, password: String) -> AuthOutcome
    producer changePassword(username: String, currentPassword: String, newPassword: String) -> AuthOutcome
    producer resetPassword(username: String, newPassword: String) -> AuthOutcome
    producer createUser(username: String, password: String, role: String, profileName: String, email: String, avatar: String) -> AuthOutcome
    producer listUsers() -> List<UserRecord>
    producer findUser(username: String) -> UserRecord
}
