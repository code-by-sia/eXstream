import "std/json.xi"
import "std/query.xi"

// Flat row matching the `users` table columns (field names == column names,
// `id` holds the username), read/written entirely through the generic
// QueryProvider — no hand-built SQL.
type UserRow = { id: String, password_hash: String, role: String, profile_name: String, email: String, avatar: String }

class SqliteUserRepository implements UserRepository {
    deps { db: QueryProvider }

    producer find(username: String) -> UserRow? {
        return query.from<UserRow>("users")
            .filter { it.id == username }
            .first(db)
    }

    producer all() -> List<UserRow> {
        return query.from<UserRow>("users")
            .sortedBy { it.id }
            .collect(db)
    }

    consumer save(row: UserRow) { db.insert("users", row as Json) }
}

// Opens the auth database and ensures its schema, then attaches the
// connection to the shared provider. Runs once from the entry.
class AuthDatabaseInit implements DatabaseInit {
    deps { sql: sqlite.SQLite, dbPaths: DatabasePaths, binder: DatabaseBinder }
    consumer ensure() {
        let db = sql.open(dbPaths.pathFor("auth.db")).value
        sql.exec(db, """
            create table if not exists users (
                id text primary key,
                password_hash text not null,
                role text not null,
                profile_name text not null,
                email text not null,
                avatar text not null)
            """)
        binder.useDatabase(db)
    }
}
