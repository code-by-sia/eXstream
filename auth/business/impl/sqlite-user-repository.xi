import "std/crypto.xi"
import "std/json.xi"
import "std/query.xi"

// Flat row matching the `users` table columns (field names == column names) so
// the QueryProvider can hydrate it directly.
type UserRow = { username: String, password_hash: String, role: String, profile_name: String, email: String, avatar: String }

class SqliteUserRepository implements UserRepository {
    deps { sql: sqlite.SQLite, dbPaths: DatabasePaths, provider: QueryProvider, binder: DatabaseBinder }

    producer find(username: String) -> UserRecord {
        let opened = connect()
        if isErr(opened) { return emptyUser() }
        let db = opened.value

        binder.useDatabase(db)
        let rows = query.from<UserRow>("users").filter { it.username == username }.collect(provider)
        sql.close(db)

        if rows.isEmpty() { return emptyUser() }
        return fromRow(rows.get(0))
    }

    producer all() -> List<UserRecord> {
        let users = empty List<UserRecord>
        let opened = connect()
        if isErr(opened) { return users }
        let db = opened.value

        binder.useDatabase(db)
        let rows = query.from<UserRow>("users").sortedBy { it.username }.collect(provider)
        for row in rows { users.push(fromRow(row)) }
        sql.close(db)
        return users
    }

    producer save(username: String, password: String, role: String, profileName: String, email: String, avatar: String) -> Bool {
        let opened = connect()
        if isErr(opened) { return false }
        let db = opened.value

        let params = json.array()
        params = json.push(params, json.str(username))
        params = json.push(params, json.str(crypto.sha256Hex(password)))
        params = json.push(params, json.str(role))
        params = json.push(params, json.str(profileName))
        params = json.push(params, json.str(email))
        params = json.push(params, json.str(avatar))

        let written = sql.execBound(db, """
            insert into users (username, password_hash, role, profile_name, email, avatar)
            values (?, ?, ?, ?, ?, ?)
            on conflict(username) do update set
                password_hash = excluded.password_hash,
                role = excluded.role,
                profile_name = excluded.profile_name,
                email = excluded.email,
                avatar = excluded.avatar
            """, params)
        sql.close(db)
        return isOk(written)
    }

    // Opens the auth database and guarantees the schema exists. Opened per
    // operation; the caller closes the returned connection.
    producer connect() -> sqlite.Database! {
        let db = sql.open(dbPaths.pathFor("auth.db"))?
        sql.exec(db, """
            create table if not exists users (
                username text primary key,
                password_hash text not null,
                role text not null,
                profile_name text not null,
                email text not null,
                avatar text not null)
            """)?
        return ok(db)
    }

    mapper fromRow(row: UserRow) -> UserRecord {
        return UserRecord {
            found: true,
            username: row.username,
            passwordHash: row.password_hash,
            role: row.role,
            profileName: row.profile_name,
            email: row.email,
            avatar: row.avatar
        }
    }

    mapper emptyUser() -> UserRecord {
        return UserRecord { found: false, username: "", passwordHash: "", role: "", profileName: "", email: "", avatar: "" }
    }
}
