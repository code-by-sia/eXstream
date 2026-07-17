// Public domain shape for a user (used by AuthService/AuthOutcome and the API
// layer). Persistence uses UserRow (impl/sqlite-user-repository.xi); AuthManager
// converts between the two.
type UserRecord = { found: Bool, username: String, passwordHash: String, role: String, profileName: String, email: String, avatar: String }

// Result carried out of the AuthService use-cases (see auth-service.xi). Kept
// here so its embedded UserRecord value is defined in the same file.
type AuthOutcome = { status: String, user: UserRecord, token: String }

// Persistence boundary for users, over std/data's QueryProvider. Implemented
// by SqliteUserRepository.
interface UserRepository {
    producer find(username: String) -> UserRow?
    producer all() -> List<UserRow>
    consumer save(row: UserRow)
}
