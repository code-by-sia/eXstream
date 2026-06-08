import "std/crypto.xi"
import "std/fs.xi"
import "std/path.xi"
import "std/text.xi"

producer userRoot() -> String {
    let d = path.join(fs.cwd(), "data/auth/users")
    fs.mkdirAll(d)
    return d
}

mapper userPath(username: String) -> String {
    return path.join(path.join(fs.cwd(), "data/auth/users"), crypto.sha256Hex(text.toLower(username)) + ".txt")
}

class FileUserRepository implements UserRepository {
    deps {}

    producer find(username: String) -> UserRecord {
        let p = userPath(username)
        if not fs.isFile(p) {
            return UserRecord { found: false, username: "", passwordHash: "", role: "" }
        }

        let content = fs.readFile(p)
        if isErr(content) {
            return UserRecord { found: false, username: "", passwordHash: "", role: "" }
        }

        let lines = text.split(content.value, "\n")
        if lines.len < 3 {
            return UserRecord { found: false, username: "", passwordHash: "", role: "" }
        }

        return UserRecord {
            found: true,
            username: lines.data[0],
            passwordHash: lines.data[1],
            role: lines.data[2]
        }
    }

    producer save(username: String, password: String, role: String) -> Bool {
        userRoot()
        let body = username + "\n" + crypto.sha256Hex(password) + "\n" + role
        return fs.writeFile(userPath(username), body)
    }
}
