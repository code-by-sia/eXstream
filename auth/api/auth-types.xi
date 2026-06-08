type RegisterRequest = { username: String, password: String, profileName: String, email: String, avatar: String }
type LoginRequest = { username: String, password: String }
type ResetPasswordRequest = { username: String, password: String }
type AuthResponse = { token: String, username: String, role: String, profileName: String, email: String, avatar: String }
type ProfileResponse = { username: String, role: String, profileName: String, email: String, avatar: String }
type Message = { ok: Bool, message: String }
