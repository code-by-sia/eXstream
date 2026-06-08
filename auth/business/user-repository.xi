type UserRecord = { found: Bool, username: String, passwordHash: String, role: String }

interface UserRepository {
    producer find(username: String) -> UserRecord
    producer save(username: String, password: String, role: String) -> Bool
}
