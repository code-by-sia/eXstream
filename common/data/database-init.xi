// Opens a service's sqlite connection, ensures its schema, and attaches it to
// the shared SqliteQueryProvider. Implemented once per service (its schema is
// service-specific); called once from the entry before web.serve.
interface DatabaseInit {
    consumer ensure()
}
