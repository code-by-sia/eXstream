import "../business/auth.xi"
import "std/config.xi"

test "issues and verifies a user token" (tokens: TokenService) {
    let token = tokens.issue("test", "USER")
    let ctx = tokens.verify(token)

    assert ctx.ok
    assert ctx.username == "test"
    assert ctx.role == "USER"
}

test "rejects a tampered token" (tokens: TokenService) {
    let ctx = tokens.verify(tokens.issue("test", "USER") + "broken")
    assert not ctx.ok
}

test "normalizes unknown roles to user" (identity: AuthIdentity) {
    assert identity.cleanRole("ADMIN") == "ADMIN"
    assert identity.cleanRole("anything") == "USER"
}

module App {
    bind AppConfig -> readConfig("common/config.yaml")
}
