import "../security-jwt.xi"
import "../../common/security/auth-identity.xi"

test "issues and verifies a user token" {
    let token = issueToken("test", "USER")
    let ctx = verifyToken(token)

    assert ctx.ok
    assert ctx.username == "test"
    assert ctx.role == "USER"
}

test "rejects a tampered token" {
    let token = issueToken("test", "USER") + "broken"
    let ctx = verifyToken(token)

    assert not ctx.ok
}

test "normalizes unknown roles to user" {
    assert cleanRole("ADMIN") == "ADMIN"
    assert cleanRole("anything") == "USER"
}

module App {}
