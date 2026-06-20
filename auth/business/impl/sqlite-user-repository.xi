import "std/crypto.xi"

class SqliteUserRepository implements UserRepository {
    deps { sql: sqlite.SQLite, reader: sqlite.RowReader, sqlText: SqlText, dbPaths: DatabasePaths }

    producer find(username: String) -> UserRecord {
        let opened = connect()
        if isErr(opened) { return emptyUser() }
        let db = opened.value

        let rows = sql.query(db, "select username, password_hash, role, profile_name, email, avatar "
            + "from users where username = '" + sqlText.escape(username) + "'")
        if isErr(rows) { sql.close(db) return emptyUser() }
        if rows.value.items.isEmpty() { sql.close(db) return emptyUser() }

        let row = rows.value.items.get(0)
        let record = UserRecord {
            found: true,
            username: reader.textAt(row, "username", ""),
            passwordHash: reader.textAt(row, "password_hash", ""),
            role: reader.textAt(row, "role", "USER"),
            profileName: reader.textAt(row, "profile_name", ""),
            email: reader.textAt(row, "email", ""),
            avatar: reader.textAt(row, "avatar", "")
        }
        sql.close(db)
        return record
    }

    producer all() -> List<UserRecord> {
        let users = empty List<UserRecord>
        let opened = connect()
        if isErr(opened) { return users }
        let db = opened.value

        let rows = sql.query(db, "select username, password_hash, role, profile_name, email, avatar from users order by username")
        if isOk(rows) {
            for row in rows.value.items {
                users.push(UserRecord {
                    found: true,
                    username: reader.textAt(row, "username", ""),
                    passwordHash: reader.textAt(row, "password_hash", ""),
                    role: reader.textAt(row, "role", "USER"),
                    profileName: reader.textAt(row, "profile_name", ""),
                    email: reader.textAt(row, "email", ""),
                    avatar: reader.textAt(row, "avatar", "")
                })
            }
        }
        sql.close(db)
        return users
    }

    producer save(username: String, password: String, role: String, profileName: String, email: String, avatar: String) -> Bool {
        let opened = connect()
        if isErr(opened) { return false }
        let db = opened.value

        let written = sql.exec(db, "insert into users (username, password_hash, role, profile_name, email, avatar) values ("
            + "'" + sqlText.escape(username) + "',"
            + "'" + sqlText.escape(crypto.sha256Hex(password)) + "',"
            + "'" + sqlText.escape(role) + "',"
            + "'" + sqlText.escape(profileName) + "',"
            + "'" + sqlText.escape(email) + "',"
            + "'" + sqlText.escape(avatar) + "') "
            + "on conflict(username) do update set "
            + "password_hash = excluded.password_hash, "
            + "role = excluded.role, "
            + "profile_name = excluded.profile_name, "
            + "email = excluded.email, "
            + "avatar = excluded.avatar")
        sql.close(db)
        return isOk(written)
    }

    // Opens the auth database and guarantees the schema exists. Opened per
    // operation; the caller closes the returned connection.
    producer connect() -> sqlite.Database! {
        let db = sql.open(dbPaths.pathFor("auth.db"))?
        sql.exec(db, "create table if not exists users ("
            + "username text primary key,"
            + "password_hash text not null,"
            + "role text not null,"
            + "profile_name text not null,"
            + "email text not null,"
            + "avatar text not null)")?
        return ok(db)
    }

    mapper emptyUser() -> UserRecord {
        return UserRecord { found: false, username: "", passwordHash: "", role: "", profileName: "", email: "", avatar: "" }
    }
}
