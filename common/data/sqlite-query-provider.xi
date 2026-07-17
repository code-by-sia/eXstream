import "std/json.xi"
import "std/query.xi"
import "std/sql.xi"
// sqlite.SQLite/Database/Rows/ColumnDecoder come from ../sqlite/sqlite.xi,
// gathered by the module's own includes glob (not imported here — the glob
// already loads it, and a second import of the same files by a different
// literal path duplicates their C typedefs).

// Bare (non-deps) parameter positions can't take a dotted/namespaced type
// name in this Xi version — alias to an unqualified name for those spots.
type Database = sqlite.Database
type Rows = sqlite.Rows

// Attaches an open connection to a SqliteQueryProvider. Bind alongside
// QueryProvider `as singleton` so both views share the same instance.
interface DatabaseBinder {
    consumer useDatabase(db: Database)
}

// Escape hatch for the rare read the plan model can't express (a cross-table
// join) — parameterized SQL on the provider's own connection. Bind alongside
// QueryProvider/DatabaseBinder `as singleton`.
interface RawSqlProvider {
    producer queryRaw(sqlText: String, params: Json) -> sqlite.Rows!
}

// A generic QueryProvider over one sqlite connection — every std/data
// Repository/CrudRepository in eXstream runs on this. `run` renders a
// std/query plan through SqlDialect (parameterized, injection-safe); `insert`
// upserts by `id` and `remove` deletes by key, both from the row's own JSON
// keys, so no per-entity SQL glue is needed.
class SqliteQueryProvider implements QueryProvider, DatabaseBinder, RawSqlProvider {
    deps { sql: sqlite.SQLite, decoder: sqlite.ColumnDecoder }
    state { db: sqlite.Database = empty sqlite.Database }

    consumer useDatabase(database: Database) { this.db = database }

    producer queryRaw(sqlText: String, params: Json) -> sqlite.Rows! => sql.queryBound(this.db, sqlText, params)

    mapper name() -> String => "sqlite"

    producer run(plan: QueryPlan) -> Json {
        let rendered = sqlRender(plan, SqliteDialect {} as SqlDialect)
        if isErr(rendered) { return fail(rendered.err) }
        let st = rendered.value
        let rows = sql.queryBound(this.db, st.text, st.params)
        if isErr(rows) { return fail(rows.err) }
        return rowsToJson(rows.value)
    }

    // Upsert by "id": delete any existing row, then insert every key present
    // in `row` as a column, positionally bound.
    consumer insert(source: String, row: Json) {
        sql.execBound(this.db, "delete from " + source + " where id = ?", oneParam(json.get(row, "id")))

        let n = json.length(row)
        let cols = ""
        let marks = ""
        let params = json.array()
        let i = 0
        while i < n {
            let key = json.keyAt(row, i)
            if i > 0 { cols = cols + ", " marks = marks + ", " }
            cols = cols + key
            marks = marks + "?"
            params = json.push(params, json.get(row, key))
            i = i + 1
        }
        sql.execBound(this.db, "insert into " + source + " (" + cols + ") values (" + marks + ")", params)
    }

    consumer remove(source: String, key: String, id: Json) {
        sql.execBound(this.db, "delete from " + source + " where " + key + " = ?", oneParam(id))
    }

    mapper oneParam(v: Json) -> Json {
        let params = json.array()
        return json.push(params, v)
    }

    mapper rowsToJson(rows: Rows) -> Json {
        let out = json.array()
        for row in rows.items {
            let obj = json.object()
            for name in row.columns.keys() {
                obj = json.set(obj, name, decoder.toJson(row.columns.get(name)))
            }
            out = json.push(out, obj)
        }
        return out
    }

    // A provider cannot honor this plan/statement — fail loudly (run has no
    // error channel), naming the problem.
    producer fail(message: String) -> Json {
        system.stdout.writeln("sqlite provider: " + message)
        assert false
        return json.array()
    }
}
