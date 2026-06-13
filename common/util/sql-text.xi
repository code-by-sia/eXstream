// Escapes a string for safe inclusion in a single-quoted SQL literal.
// xi-sqlite has no parameter binding, so values are escaped by doubling single
// quotes. Implemented by SqlTextEscaper.
interface SqlText {
    mapper escape(s: String) -> String
}
