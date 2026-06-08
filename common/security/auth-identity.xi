import "std/text.xi"
import "std/web.xi"

type AuthContext = { ok: Bool, username: String, role: String }

mapper cleanRole(role: String) -> String {
    if text.toUpper(role) == "ADMIN" { return "ADMIN" }
    return "USER"
}

mapper bearerToken(header: String) -> String {
    if text.startsWith(header, "Bearer ") {
        return text.substring(header, 7, text.length(header))
    }
    return ""
}

mapper protectedContext(req: HttpRequest) -> AuthContext {
    let username = req.header("X-Username")
    let role = cleanRole(req.header("X-Role"))
    if text.isEmpty(username) { return AuthContext { ok: false, username: "", role: "" } }
    return AuthContext { ok: true, username: username, role: role }
}

predicate hasIdentity(req: HttpRequest) {
    if text.isEmpty(req.header("X-Username")) { return false }
    let role = req.header("X-Role")
    if role != "ADMIN" and role != "USER" { return false }
    return true
}

mapper roleOf(req: HttpRequest) -> String {
    return cleanRole(req.header("X-Role"))
}
