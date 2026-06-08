import "std/text.xi"

mapper jsonString(s: String) -> String {
    let out = text.replace(s, "\\", "\\\\")
    out = text.replace(out, "\"", "\\\"")
    out = text.replace(out, "\n", "\\n")
    return "\"" + out + "\""
}
