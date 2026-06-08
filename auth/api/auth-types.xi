type RegisterRequest = { username: String, password: String }
type LoginRequest = { username: String, password: String }
type ResetPasswordRequest = { username: String, password: String }
type AuthResponse = { token: String, username: String, role: String }
type ProfileResponse = { username: String, role: String }
type Message = { ok: Bool, message: String }
