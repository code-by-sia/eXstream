// Wiring barrel for the auth service. Imports every local file exactly once in
// dependency order: shared common interfaces/impls, the SQLite bindings, then
// this service's interfaces, implementations, and HTTP layer. Later files
// reference earlier types/classes globally without re-importing them.
import "../../common/config/app-config.xi"
import "../../common/security/auth-context.xi"
import "../../common/security/auth-identity.xi"
import "../../common/security/impl/http-auth-identity.xi"
import "../../common/util/sql-text.xi"
import "../../common/util/impl/sql-text-escaper.xi"
import "../../common/util/database-paths.xi"
import "../../common/util/impl/file-database-paths.xi"
import "../../vendor/sqlite.xi"
import "user-repository.xi"
import "token-service.xi"
import "auth-service.xi"
import "data-seeder.xi"
import "impl/sqlite-user-repository.xi"
import "impl/jwt-token-service.xi"
import "impl/auth-manager.xi"
import "impl/user-data-seeder.xi"
import "../api/auth-types.xi"
import "../api/auth-api.xi"
