import "std/text.xi"

mapper cleanField(s: String) -> String {
    let out = text.replace(s, "|", " ")
    out = text.replace(out, "\n", " ")
    return text.trim(out)
}

mapper lineOr(lines: String[], i: Integer) -> String {
    if i < lines.len { return lines.data[i] }
    return ""
}

mapper ownerOf(content: String) -> String {
    let lines = text.split(content, "\n")
    return lineOr(lines, 2)
}

predicate canAccess(content: String, username: String, role: String) {
    if role == "ADMIN" { return true }
    return ownerOf(content) == username
}

mapper trackJson(parts: String[]) -> String {
    return "{"
        + "\"id\":" + jsonString(parts.data[0]) + ","
        + "\"title\":" + jsonString(parts.data[1]) + ","
        + "\"artist\":" + jsonString(parts.data[2]) + ","
        + "\"url\":" + jsonString(parts.data[3]) + ","
        + "\"addedBy\":" + jsonString(parts.data[4])
        + "}"
}

mapper playlistJson(id: String, content: String) -> String {
    let lines = text.split(content, "\n")
    let tracks = "["
    let first = true
    let i = 3
    while i < lines.len {
        let parts = text.split(lines.data[i], "|")
        if parts.len >= 5 {
            if not first { tracks = tracks + "," }
            first = false
            tracks = tracks + trackJson(parts)
        }
        i = i + 1
    }

    return "{"
        + "\"id\":" + jsonString(id) + ","
        + "\"name\":" + jsonString(lineOr(lines, 0)) + ","
        + "\"description\":" + jsonString(lineOr(lines, 1)) + ","
        + "\"owner\":" + jsonString(lineOr(lines, 2)) + ","
        + "\"tracks\":" + tracks + "]"
        + "}"
}
