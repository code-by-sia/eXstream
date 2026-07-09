import "std/crypto.xi"
import "std/json.xi"
import "std/text.xi"
import "std/web.xi"

class FileApi implements WebRequestHandler {
    deps { files: FileRepository, identity: AuthIdentity, paths: FilePaths }

    mapper getBaseUrl() -> String => "/"

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/health" {
        res.send(FileMessage { ok: true, message: "file service up" })
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/files" and req.method == "GET" {
        if not identity.hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        res.sendText(200, fileListJson(files.list()))
    }

    action handle(req: HttpRequest, res: HttpResponse) where req.path == "/file" and req.method == "POST" {
        if not identity.hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }
        let filePath = "music/" + newUuid()
        let result = files.create(filePath, req.body)
        if result == "created" {
            res.send(UploadResult { ok: true, path: filePath, url: "/file/" + filePath })
            return
        }
        res.sendStatus(500, "failed to upload file")
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "GET" {
        if not identity.hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let filePath = paths.fromRequest(req)
        if not paths.isSafe(filePath) {
            res.sendStatus(400, "file path must be a safe relative path")
            return
        }

        let file = files.get(filePath)
        if not file.found {
            res.sendStatus(404, "file not found")
            return
        }
        res.send(FileBody { path: file.path, content: file.content })
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "POST" {
        if not identity.hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let body = web.body(req) as FileWrite
        let result = files.create(paths.fromRequest(req), body.content)
        sendWriteResult(res, result, "create")
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "PUT" {
        if not identity.hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let body = web.body(req) as FileWrite
        let result = files.update(paths.fromRequest(req), body.content)
        sendWriteResult(res, result, "update")
    }

    action handle(req: HttpRequest, res: HttpResponse) where text.startsWith(req.path, "/file/") and req.method == "DELETE" {
        if not identity.hasIdentity(req) { res.sendStatus(403, "missing identity headers") return }

        let result = files.delete(paths.fromRequest(req))
        sendWriteResult(res, result, "delete")
    }

    action handle(req: HttpRequest, res: HttpResponse) {
        res.sendStatus(404, "Not Found")
    }

    mapper newUuid() -> String {
        return crypto.randomHex(4) + "-"
            + crypto.randomHex(2) + "-"
            + crypto.randomHex(2) + "-"
            + crypto.randomHex(2) + "-"
            + crypto.randomHex(6)
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
