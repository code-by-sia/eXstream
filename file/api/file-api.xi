import "std/crypto.xi"
import "std/fs.xi"
import "std/path.xi"
import "std/text.xi"
import "std/web.xi"
import "file-types.xi"
import "../business/file-paths.xi"
import "../business/file-repository.xi"
import "../../common/security/auth-identity.xi"

class FileApi implements WebRequestHandler {
    deps { files: FileRepository }

    mapper getBaseUrl() -> String => "/"

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/health" {
        res.send(FileMessage { ok: true, message: "file service up" })
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/files" and req.method == "GET" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        res.send(FileList { files: files.list() })
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/file" and req.method == "POST" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        let filePath = "music/" + newUuid()
        let target = storagePath(filePath)
        fs.mkdirAll(path.dirname(target))
        if fs.writeFile(target, req.body) {
            res.sendText(200, "{\"ok\":true,\"path\":\"" + filePath + "\",\"url\":\"/file/" + filePath + "\"}")
            return
        }
        res.sendStatus(500, "failed to upload file")
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "GET" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let filePath = requestFilePath(req)
        if not safePath(filePath) {
            res.sendStatus(400, "file path must be a safe relative path")
            return
        }

        let file = files.get(filePath)
        if text.isEmpty(file.content) and not fs.isFile(storagePath(filePath)) {
            res.sendStatus(404, "file not found")
            return
        }
        res.send(FileBody { path: file.path, content: file.content })
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "POST" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let body = req.parse(FileWrite)
        let result = files.create(requestFilePath(req), body.content)
        sendWriteResult(res, result, "create")
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "PUT" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let body = req.parse(FileWrite)
        let result = files.update(requestFilePath(req), body.content)
        sendWriteResult(res, result, "update")
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "DELETE" {
        if not hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let result = files.delete(requestFilePath(req))
        sendWriteResult(res, result, "delete")
    }

    action handle(req: HttpRequest, res: HttpResponse) {
        res.sendStatus(404, "Not Found")
    }
}

mapper newUuid() -> String {
    return crypto.randomHex(4) + "-"
        + crypto.randomHex(2) + "-"
        + crypto.randomHex(2) + "-"
        + crypto.randomHex(2) + "-"
        + crypto.randomHex(6)
}

consumer sendWriteResult(res: HttpResponse, result: String, operation: String) {
    if result == "created" or result == "updated" or result == "deleted" {
        res.send(FileMessage { ok: true, message: result })
        return
    }
    if result == "already-exists" { res.sendStatus(409, "file already exists") return }
    if result == "not-found" { res.sendStatus(404, "file not found") return }
    if result == "invalid-path" { res.sendStatus(400, "file path must be a safe relative path") return }
    res.sendStatus(500, "failed to " + operation + " file")
}
