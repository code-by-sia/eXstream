// Wiring barrel for the file service. Imports every local file once in
// dependency order; later files reference earlier types/classes globally.
import "../../common/config/app-config.xi"
import "../../common/security/auth-context.xi"
import "../../common/security/auth-identity.xi"
import "../../common/security/impl/http-auth-identity.xi"
import "../../common/util/json-text.xi"
import "../../common/util/impl/json-text-encoder.xi"
import "file-repository.xi"
import "file-paths.xi"
import "impl/disk-file-repository.xi"
import "impl/request-file-paths.xi"
import "../api/file-types.xi"
import "../api/file-api.xi"
