import "../business/files.xi"
import "std/config.xi"

test "creates and reads stored files" (repo: FileRepository) {
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

module App {
    bind AppConfig -> readConfig("common/config.yaml")
}
