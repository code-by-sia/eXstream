type UserRecord = { found: Bool, username: String, passwordHash: String, role: String, profileName: String, email: String, avatar: String }

interface UserRepository {
    producer find(username: String) -> UserRecord
    producer save(username: String, password: String, role: String, profileName: String, email: String, avatar: String) -> Bool
}
