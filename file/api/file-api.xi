import "std/json.xi"
import "std/text.xi"
import "std/web.xi"

class FileApi implements WebRequestHandler {
    deps { service: FileService, identity: AuthIdentity, paths: FilePaths }

    mapper getBaseUrl() -> String => "/"

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/health" {
        res.send(FileMessage { ok: true, message: "file service up" })
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/files" and req.method == "GET" {
        if not requireIdentity(req, res) { return }
        res.sendText(200, fileListJson(service.list()))
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/file" and req.method == "POST" {
        if not requireIdentity(req, res) { return }
        let stored = service.store(req.body)
        if not stored.found { res.sendStatus(500, "failed to upload file") return }
        res.send(UploadResult { ok: true, path: stored.path, url: "/file/" + stored.path })
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "GET" {
        if not requireIdentity(req, res) { return }

        let filePath = paths.fromRequest(req)
        if not paths.isSafe(filePath) {
            res.sendStatus(400, "file path must be a safe relative path")
            return
        }

        let file = service.read(filePath)
        if not file.found {
            res.sendStatus(404, "file not found")
            return
        }
        res.send(FileBody { path: file.path, content: file.content })
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "POST" {
        if not requireIdentity(req, res) { return }

        let body = web.body(req) as FileWrite
        sendWriteResult(res, service.create(paths.fromRequest(req), body.content), "create")
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "PUT" {
        if not requireIdentity(req, res) { return }

        let body = web.body(req) as FileWrite
        sendWriteResult(res, service.update(paths.fromRequest(req), body.content), "update")
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "DELETE" {
        if not requireIdentity(req, res) { return }

        sendWriteResult(res, service.delete(paths.fromRequest(req)), "delete")
    }

    action handle(req: HttpRequest, res: HttpResponse) {
        res.sendStatus(404, "Not Found")
    }

    // Ensures identity headers are present; writes 403 and returns false if not.
    producer requireIdentity(req: HttpRequest, res: HttpResponse) -> Bool {
        if identity.hasIdentity(req) { return true }
        res.sendStatus(403, "missing identity headers")
        return false
    }

    mapper fileListJson(filePaths: List<String>) -> String {
        let arr = json.array()
        for p in filePaths { arr = json.push(arr, json.str(p)) }
        let root = json.object()
        root = json.set(root, "files", arr)
        return json.stringify(root)
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
}
