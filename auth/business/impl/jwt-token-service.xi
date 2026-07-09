import "std/bytes.xi"
import "std/crypto.xi"
import "std/json.xi"
import "std/process.xi"
import "std/text.xi"

class JwtTokenService implements TokenService {
    deps { identity: AuthIdentity }

    mapper issue(username: String, role: String) -> String {
        let claims = json.object()
        claims = json.set(claims, "sub", json.str(username))
        claims = json.set(claims, "role", json.str(role))

        let header = base64UrlText("{\"alg\":\"HS256\",\"typ\":\"JWT\"}")
        let payload = base64UrlText(json.stringify(claims))
        let signingInput = header + "." + payload
        return signingInput + "." + jwtSignature(signingInput)
    }

    mapper verify(token: String) -> AuthContext {
        let parts = text.split(token, ".")
        if parts.len != 3 { return AuthContext { ok: false, username: "", role: "" } }

        let signingInput = parts.data[0] + "." + parts.data[1]
        if jwtSignature(signingInput) != parts.data[2] {
            return AuthContext { ok: false, username: "", role: "" }
        }

        let payload = json.parse(decodeBase64Url(parts.data[1]))
        if not json.isValid(payload) { return AuthContext { ok: false, username: "", role: "" } }

        let username = json.getString(payload, "sub")
        let role = identity.cleanRole(json.getString(payload, "role"))
        if text.isEmpty(username) { return AuthContext { ok: false, username: "", role: "" } }
        return AuthContext { ok: true, username: username, role: role }
    }

    mapper jwtSecret() -> String {
        return proc.envOr("JWT_SECRET", "dev-secret")
    }

    mapper base64UrlText(s: String) -> String {
        return base64UrlBytes(bytes.fromString(s))
    }

    mapper base64UrlBytes(b: Bytes) -> String {
        let out = crypto.base64(b)
        out = text.replace(out, "+", "-")
        out = text.replace(out, "/", "_")
        out = text.replace(out, "=", "")
        return out
    }

    mapper decodeBase64Url(s: String) -> String {
        let out = text.replace(s, "-", "+")
        out = text.replace(out, "_", "/")
        let rem = text.length(out) % 4
        if rem == 2 { out = out + "==" }
        if rem == 3 { out = out + "=" }
        return bytes.toString(crypto.fromBase64(out))
    }

    mapper jwtSignature(signingInput: String) -> String {
        return base64UrlBytes(crypto.hmacSha256(bytes.fromString(jwtSecret()), bytes.fromString(signingInput)))
    }
}
