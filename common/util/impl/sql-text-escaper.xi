import "std/text.xi"

class SqlTextEscaper implements SqlText {
    deps {}

    mapper escape(s: String) -> String {
        return text.replace(s, "'", "''")
    }
}
