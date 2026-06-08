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
            return emptyUser()
        }

        let content = fs.readFile(p)
        if isErr(content) {
            return emptyUser()
        }

        let lines = text.split(content.value, "\n")
        if lines.len < 3 {
            return emptyUser()
        }

        let profileName = lines.data[0]
        let email = ""
        let avatar = ""
        if lines.len >= 4 { profileName = lines.data[3] }
        if lines.len >= 5 { email = lines.data[4] }
        if lines.len >= 6 { avatar = lines.data[5] }

        return UserRecord {
            found: true,
            username: lines.data[0],
            passwordHash: lines.data[1],
            role: lines.data[2],
            profileName: profileName,
            email: email,
            avatar: avatar
        }
    }

    producer save(username: String, password: String, role: String, profileName: String, email: String, avatar: String) -> Bool {
        userRoot()
        let body = cleanUserField(username) + "\n"
            + crypto.sha256Hex(password) + "\n"
            + role + "\n"
            + cleanUserField(profileName) + "\n"
            + cleanUserField(email) + "\n"
            + cleanUserField(avatar)
        return fs.writeFile(userPath(username), body)
    }
}

mapper emptyUser() -> UserRecord {
    return UserRecord { found: false, username: "", passwordHash: "", role: "", profileName: "", email: "", avatar: "" }
}

mapper cleanUserField(raw: String) -> String {
    let out = text.replace(raw, "\n", " ")
    return text.replace(out, "\r", " ")
}
