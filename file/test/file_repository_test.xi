import "../business/file-repository.xi"
import "../business/disk-file-repository.xi"

test "creates and reads stored files" {
    let repo = App.resolve(FileRepository)
    let filePath = "test/codex-repository.txt"

    repo.delete(filePath)

    assert repo.create(filePath, "hello") == "created"

    let stored = repo.get(filePath)
    assert stored.path == filePath
    assert stored.content == "hello"

    assert repo.delete(filePath) == "deleted"
}

module App {}
