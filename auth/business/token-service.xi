// Issues and verifies the HS256 JWTs used across the platform. Implemented by
// JwtTokenService.
interface TokenService {
    mapper issue(username: String, role: String) -> String
    mapper verify(token: String) -> AuthContext
}
