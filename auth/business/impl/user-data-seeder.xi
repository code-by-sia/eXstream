import "std/crypto.xi"

class UserDataSeeder implements DataSeeder {
    deps { users: UserRepository }

    action seedDefaultUsers() {
        seedIfMissing("admin", "admin123", "ADMIN", "Admin", "admin@exstream.local", "🎛️")
        seedIfMissing("test", "test123", "USER", "Test Listener", "test@exstream.local", "🎧")
    }

    action seedIfMissing(username: String, password: String, role: String, profileName: String, email: String, avatar: String) {
        if let existing = users.find(username) { return }
        users.save(UserRow { id: username, password_hash: crypto.sha256Hex(password), role: role, profile_name: profileName, email: email, avatar: avatar })
    }
}
