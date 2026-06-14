import "std/crypto.xi"
import "std/text.xi"

class SqlitePlaylistRepository implements PlaylistRepository {
    deps { sql: sqlite.SQLite, reader: sqlite.RowReader, sqlText: SqlText, dbPaths: DatabasePaths }

    producer get(id: String) -> Playlist {
        let opened = connect()
        if isErr(opened) { return missingPlaylist(id) }
        let db = opened.value

        let rows = sql.query(db, "select id, name, description, owner from playlists where id = '" + sqlText.escape(id) + "'")
        if isErr(rows) or rows.value.items.isEmpty() { sql.close(db) return missingPlaylist(id) }

        let playlist = playlistFromRow(rows.value.items.get(0), loadTracks(db, id))
        sql.close(db)
        return playlist
    }

    producer listForUser(username: String, role: String) -> List<Playlist> {
        return queryPlaylists(ownerFilter("owner", username, role))
    }

    producer searchPlaylists(query: String, username: String, role: String) -> List<Playlist> {
        let filter = ownerFilter("owner", username, role)
            + " and (" + likeClause("name", query) + " or " + likeClause("description", query) + ")"
        return queryPlaylists(filter)
    }

    producer searchTracks(query: String, username: String, role: String) -> List<MusicHit> {
        let hits = empty List<MusicHit>
        let opened = connect()
        if isErr(opened) { return hits }
        let db = opened.value

        let rows = sql.query(db, "select t.id, t.playlist_id, t.title, t.artist, t.url, t.added_by, t.cover_url "
            + "from tracks t join playlists p on p.id = t.playlist_id "
            + "where (" + ownerFilter("p.owner", username, role) + ") "
            + "and (" + likeClause("t.title || ' ' || t.artist", query) + ") "
            + "order by p.id, t.position, t.rowid")
        if isOk(rows) {
            for row in rows.value.items {
                hits.push(MusicHit {
                    id: reader.textAt(row, "id", ""),
                    playlistId: reader.textAt(row, "playlist_id", ""),
                    title: reader.textAt(row, "title", ""),
                    artist: reader.textAt(row, "artist", ""),
                    url: reader.textAt(row, "url", ""),
                    addedBy: reader.textAt(row, "added_by", ""),
                    coverUrl: reader.textAt(row, "cover_url", "")
                })
            }
        }
        sql.close(db)
        return hits
    }

    producer create(name: String, description: String, owner: String) -> String {
        let opened = connect()
        if isErr(opened) { return "" }
        let db = opened.value

        let id = crypto.randomHex(8)
        let written = sql.exec(db, "insert into playlists (id, name, description, owner) values ("
            + "'" + sqlText.escape(id) + "', '" + sqlText.escape(name) + "', '" + sqlText.escape(description) + "', '" + sqlText.escape(owner) + "')")
        sql.close(db)
        if isErr(written) { return "" }
        return id
    }

    producer remove(id: String) -> Bool {
        let opened = connect()
        if isErr(opened) { return false }
        let db = opened.value

        let written = sql.exec(db, "delete from tracks where playlist_id = '" + sqlText.escape(id) + "';"
            + "delete from playlists where id = '" + sqlText.escape(id) + "'")
        sql.close(db)
        return isOk(written)
    }

    producer addTrack(id: String, title: String, artist: String, url: String, addedBy: String, coverUrl: String) -> String {
        let opened = connect()
        if isErr(opened) { return "" }
        let db = opened.value

        let trackId = crypto.randomHex(8)
        let written = sql.exec(db, "insert into tracks (id, playlist_id, title, artist, url, added_by, cover_url, position) values ("
            + "'" + sqlText.escape(trackId) + "', '" + sqlText.escape(id) + "', '" + sqlText.escape(title) + "', '" + sqlText.escape(artist) + "', "
            + "'" + sqlText.escape(url) + "', '" + sqlText.escape(addedBy) + "', '" + sqlText.escape(coverUrl) + "', "
            + "(select count(*) from tracks where playlist_id = '" + sqlText.escape(id) + "'))")
        sql.close(db)
        if isErr(written) { return "" }
        return trackId
    }

    producer updateTrack(id: String, trackId: String, title: String, artist: String, url: String, coverUrl: String) -> String {
        let opened = connect()
        if isErr(opened) { return "storage-failed" }
        let db = opened.value

        let written = sql.exec(db, "update tracks set "
            + "title = '" + sqlText.escape(title) + "', artist = '" + sqlText.escape(artist) + "', "
            + "url = '" + sqlText.escape(url) + "', cover_url = '" + sqlText.escape(coverUrl) + "' "
            + "where id = '" + sqlText.escape(trackId) + "' and playlist_id = '" + sqlText.escape(id) + "'")
        if isErr(written) { sql.close(db) return "storage-failed" }
        let changed = sql.changes(db)
        sql.close(db)
        if changed == 0 { return "not-found" }
        return "updated"
    }

    producer deleteTrack(id: String, trackId: String) -> String {
        let opened = connect()
        if isErr(opened) { return "storage-failed" }
        let db = opened.value

        let written = sql.exec(db, "delete from tracks where id = '" + sqlText.escape(trackId) + "' and playlist_id = '" + sqlText.escape(id) + "'")
        if isErr(written) { sql.close(db) return "storage-failed" }
        let changed = sql.changes(db)
        sql.close(db)
        if changed == 0 { return "not-found" }
        return "deleted"
    }

    // Moves a track to another playlist atomically: a single UPDATE reassigns
    // the row and appends it to the end of the target's order. The track keeps
    // its id, so there is no add-then-delete duplication window.
    producer moveTrack(id: String, trackId: String, targetId: String) -> String {
        let opened = connect()
        if isErr(opened) { return "storage-failed" }
        let db = opened.value

        let written = sql.exec(db, "update tracks set "
            + "playlist_id = '" + sqlText.escape(targetId) + "', "
            + "position = (select count(*) from tracks where playlist_id = '" + sqlText.escape(targetId) + "') "
            + "where id = '" + sqlText.escape(trackId) + "' and playlist_id = '" + sqlText.escape(id) + "'")
        if isErr(written) { sql.close(db) return "storage-failed" }
        let changed = sql.changes(db)
        sql.close(db)
        if changed == 0 { return "not-found" }
        return "moved"
    }

    // Opens the playlist database and guarantees the schema exists.
    producer connect() -> sqlite.Database! {
        let db = sql.open(dbPaths.pathFor("playlists.db"))?
        sql.exec(db, "create table if not exists playlists ("
            + "id text primary key,"
            + "name text not null,"
            + "description text not null,"
            + "owner text not null);"
            + "create table if not exists tracks ("
            + "id text primary key,"
            + "playlist_id text not null,"
            + "title text not null,"
            + "artist text not null,"
            + "url text not null,"
            + "added_by text not null,"
            + "cover_url text not null,"
            + "position integer not null)")?
        return ok(db)
    }

    // Shared read path for list/search: selects playlist rows matching `filter`
    // and hydrates each with its tracks.
    producer queryPlaylists(filter: String) -> List<Playlist> {
        let result = empty List<Playlist>
        let opened = connect()
        if isErr(opened) { return result }
        let db = opened.value

        let rows = sql.query(db, "select id, name, description, owner from playlists where " + filter + " order by name")
        if isErr(rows) { sql.close(db) return result }

        for row in rows.value.items {
            result.push(playlistFromRow(row, loadTracks(db, reader.textAt(row, "id", ""))))
        }
        sql.close(db)
        return result
    }

    producer loadTracks(db: sqlite.Database, playlistId: String) -> List<Track> {
        let tracks = empty List<Track>
        let rows = sql.query(db, "select id, title, artist, url, added_by, cover_url from tracks "
            + "where playlist_id = '" + sqlText.escape(playlistId) + "' order by position, rowid")
        if isOk(rows) {
            for row in rows.value.items {
                tracks.push(Track {
                    id: reader.textAt(row, "id", ""),
                    title: reader.textAt(row, "title", ""),
                    artist: reader.textAt(row, "artist", ""),
                    url: reader.textAt(row, "url", ""),
                    addedBy: reader.textAt(row, "added_by", ""),
                    coverUrl: reader.textAt(row, "cover_url", "")
                })
            }
        }
        return tracks
    }

    producer playlistFromRow(row: sqlite.Row, tracks: List<Track>) -> Playlist {
        return Playlist {
            found: true,
            id: reader.textAt(row, "id", ""),
            name: reader.textAt(row, "name", ""),
            description: reader.textAt(row, "description", ""),
            owner: reader.textAt(row, "owner", ""),
            tracks: tracks
        }
    }

    // SQL predicate restricting rows to playlists the caller may see: any row
    // for an admin, otherwise only the caller's own.
    mapper ownerFilter(column: String, username: String, role: String) -> String {
        if role == "ADMIN" { return "1 = 1" }
        return column + " = '" + sqlText.escape(username) + "'"
    }

    mapper likeClause(column: String, query: String) -> String {
        if text.isEmpty(query) { return "1 = 1" }
        return "lower(" + column + ") like '%" + sqlText.escape(text.toLower(query)) + "%'"
    }

    mapper missingPlaylist(id: String) -> Playlist {
        return Playlist { found: false, id: id, name: "", description: "", owner: "", tracks: empty List<Track> }
    }
}
