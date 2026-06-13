class UserDataSeeder implements DataSeeder {
    deps { users: UserRepository }

    action seedDefaultUsers() {
        let admin = users.find("admin")
        if not admin.found {
            users.save("admin", "admin123", "ADMIN", "Admin", "admin@exstream.local", "🎛️")
        }

        let test = users.find("test")
        if not test.found {
            users.save("test", "test123", "USER", "Test Listener", "test@exstream.local", "🎧")
        }
    }
}
