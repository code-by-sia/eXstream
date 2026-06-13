import "std/text.xi"

class JsonTextEncoder implements JsonText {
    deps {}

    mapper encode(s: String) -> String {
        let out = text.replace(s, "\\", "\\\\")
        out = text.replace(out, "\"", "\\\"")
        out = text.replace(out, "\n", "\\n")
        return "\"" + out + "\""
    }
}
