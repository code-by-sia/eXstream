type UserRecord = { found: Bool, username: String, passwordHash: String, role: String, profileName: String, email: String, avatar: String }

// Result carried out of the AuthService use-cases (see auth-service.xi). Kept
// here so its embedded UserRecord value is defined in the same file.
type AuthOutcome = { status: String, user: UserRecord, token: String }

interface UserRepository {
    producer find(username: String) -> UserRecord
    producer all() -> List<UserRecord>
    producer save(username: String, password: String, role: String, profileName: String, email: String, avatar: String) -> Bool
}
