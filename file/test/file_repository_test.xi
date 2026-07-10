// More test blocks for the file service (gathered via the root file-test.xi).

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
