type RegisterRequest = { username: String, password: String, profileName: String, email: String, avatar: String }
type LoginRequest = { username: String, password: String }
type ChangePasswordRequest = { currentPassword: String, newPassword: String }
type AdminResetRequest = { username: String, newPassword: String }
type CreateUserRequest = { username: String, password: String, profileName: String, email: String, avatar: String, role: String }
type AuthResponse = { token: String, username: String, role: String, profileName: String, email: String, avatar: String }
type ProfileResponse = { username: String, role: String, profileName: String, email: String, avatar: String }
type Message = { ok: Bool, message: String }
