import "std/web.xi"

// Reads and normalizes the caller identity from an HTTP request: the
// `X-Username`/`X-Role` headers stamped by the ingress ForwardAuth, plus the
// bearer token helper. Implemented by HttpAuthIdentity.
interface AuthIdentity {
    mapper cleanRole(role: String) -> String
    mapper bearerToken(header: String) -> String
    mapper context(req: HttpRequest) -> AuthContext
    predicate hasIdentity(req: HttpRequest)
    mapper roleOf(req: HttpRequest) -> String
}
