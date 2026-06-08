consumer seedDefaultUsers(users: UserRepository) {
    let admin = users.find("admin")
    if not admin.found {
        users.save("admin", "admin123", "ADMIN")
    }

    let test = users.find("test")
    if not test.found {
        users.save("test", "test123", "USER")
    }
}
