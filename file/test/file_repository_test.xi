import "../business/file-repository.xi"
import "../business/sqlite-file-repository.xi"

test "creates and reads stored files" {
    let repo = App.resolve(FileRepository)
    let filePath = "test/codex-repository.txt"

    repo.delete(filePath)

    assert repo.create(filePath, "hello") == "created"

    let stored = repo.get(filePath)
    assert stored.found
    assert stored.path == filePath
    assert stored.content == "hello"

    assert repo.delete(filePath) == "deleted"
    assert not repo.get(filePath).found
}

module App {}
