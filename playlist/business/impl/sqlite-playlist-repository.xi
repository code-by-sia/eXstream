import "std/crypto.xi"
import "std/json.xi"
import "std/query.xi"
import "std/text.xi"

// Flat rows matching the table columns so the QueryProvider can hydrate them
// directly (field names == column names).
type PlaylistRow = { id: String, name: String, description: String, owner: String }
type TrackRow = { id: String, playlist_id: String, title: String, artist: String, url: String, added_by: String, cover_url: String, position: Integer }

class SqlitePlaylistRepository implements PlaylistRepository {
    deps { sql: sqlite.SQLite, reader: sqlite.RowReader, dbPaths: DatabasePaths, provider: QueryProvider, binder: DatabaseBinder }

    producer get(id: String) -> Playlist {
        let opened = connect()
        if isErr(opened) { return missingPlaylist(id) }
        let db = opened.value

        binder.useDatabase(db)
        let rows = query.from<PlaylistRow>("playlists").filter { it.id == id }.collect(provider)
        if rows.isEmpty() { sql.close(db) return missingPlaylist(id) }

        let playlist = playlistFromRow(rows.get(0), loadTracks(db, id))
        sql.close(db)
        return playlist
    }

    // A typed chain over `playlists`, restricted to the caller's own rows unless
    // they are an admin.
    producer listForUser(username: String, role: String) -> List<Playlist> {
        let result = empty List<Playlist>
        let opened = connect()
        if isErr(opened) { return result }
        let db = opened.value

        binder.useDatabase(db)
        let rows = empty List<PlaylistRow>
        if role == "ADMIN" {
            rows = query.from<PlaylistRow>("playlists").sortedBy { it.name }.collect(provider)
        } else {
            rows = query.from<PlaylistRow>("playlists").filter { it.owner == username }.sortedBy { it.name }.collect(provider)
        }
        for row in rows { result.push(playlistFromRow(row, loadTracks(db, row.id))) }
        sql.close(db)
        return result
    }

    producer searchPlaylists(term: String, username: String, role: String) -> List<Playlist> {
        let result = empty List<Playlist>
        let opened = connect()
        if isErr(opened) { return result }
        let db = opened.value

        binder.useDatabase(db)
        let needle = text.toLower(term)
        let rows = empty List<PlaylistRow>
        if role == "ADMIN" {
            rows = query.from<PlaylistRow>("playlists")
                .filter { it.name.lowercase().contains(needle) or it.description.lowercase().contains(needle) }
                .sortedBy { it.name }.collect(provider)
        } else {
            rows = query.from<PlaylistRow>("playlists")
                .filter { it.owner == username and (it.name.lowercase().contains(needle) or it.description.lowercase().contains(needle)) }
                .sortedBy { it.name }.collect(provider)
        }
        for row in rows { result.push(playlistFromRow(row, loadTracks(db, row.id))) }
        sql.close(db)
        return result
    }

    // Cross-table search (tracks joined to their playlist for the owner check);
    // the single-table QueryProvider can't express the join, so this one stays a
    // parameterized queryBound.
    producer searchTracks(term: String, username: String, role: String) -> List<MusicHit> {
        let hits = empty List<MusicHit>
        let opened = connect()
        if isErr(opened) { return hits }
        let db = opened.value

        let like = wildcard(term)
        let sqlStr = """
            select t.id, t.playlist_id, t.title, t.artist, t.url, t.added_by, t.cover_url
            from tracks t join playlists p on p.id = t.playlist_id
            where p.owner = ? and lower(t.title || ' ' || t.artist) like ?
            order by p.id, t.position, t.rowid
            """
        let params = strParams(listOf(username, like))
        if role == "ADMIN" {
            sqlStr = """
                select t.id, t.playlist_id, t.title, t.artist, t.url, t.added_by, t.cover_url
                from tracks t join playlists p on p.id = t.playlist_id
                where lower(t.title || ' ' || t.artist) like ?
                order by p.id, t.position, t.rowid
                """
            params = strParams(listOf(like))
        }
        let rows = sql.queryBound(db, sqlStr, params)
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
        let written = sql.execBound(db, "insert into playlists (id, name, description, owner) values (?, ?, ?, ?)", strParams(listOf(id, name, description, owner)))
        sql.close(db)
        if isErr(written) { return "" }
        return id
    }

    producer remove(id: String) -> Bool {
        let opened = connect()
        if isErr(opened) { return false }
        let db = opened.value

        let clearedTracks = sql.execBound(db, "delete from tracks where playlist_id = ?", strParams(listOf(id)))
        let removedPlaylist = sql.execBound(db, "delete from playlists where id = ?", strParams(listOf(id)))
        sql.close(db)
        return isOk(clearedTracks) and isOk(removedPlaylist)
    }

    producer addTrack(id: String, title: String, artist: String, url: String, addedBy: String, coverUrl: String) -> String {
        let opened = connect()
        if isErr(opened) { return "" }
        let db = opened.value

        let trackId = crypto.randomHex(8)
        let written = sql.execBound(db, """
            insert into tracks (id, playlist_id, title, artist, url, added_by, cover_url, position)
            values (?, ?, ?, ?, ?, ?, ?, (select count(*) from tracks where playlist_id = ?))
            """, strParams(listOf(trackId, id, title, artist, url, addedBy, coverUrl, id)))
        sql.close(db)
        if isErr(written) { return "" }
        return trackId
    }

    producer updateTrack(id: String, trackId: String, title: String, artist: String, url: String, coverUrl: String) -> String {
        let opened = connect()
        if isErr(opened) { return "storage-failed" }
        let db = opened.value

        let written = sql.execBound(db, """
            update tracks set title = ?, artist = ?, url = ?, cover_url = ?
            where id = ? and playlist_id = ?
            """, strParams(listOf(title, artist, url, coverUrl, trackId, id)))
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

        let written = sql.execBound(db, "delete from tracks where id = ? and playlist_id = ?", strParams(listOf(trackId, id)))
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

        let written = sql.execBound(db, """
            update tracks set
                playlist_id = ?,
                position = (select count(*) from tracks where playlist_id = ?)
            where id = ? and playlist_id = ?
            """, strParams(listOf(targetId, targetId, trackId, id)))
        if isErr(written) { sql.close(db) return "storage-failed" }
        let changed = sql.changes(db)
        sql.close(db)
        if changed == 0 { return "not-found" }
        return "moved"
    }

    // Opens the playlist database and guarantees the schema exists.
    producer connect() -> sqlite.Database! {
        let db = sql.open(dbPaths.pathFor("playlists.db"))?
        sql.exec(db, """
            create table if not exists playlists (
                id text primary key,
                name text not null,
                description text not null,
                owner text not null);
            create table if not exists tracks (
                id text primary key,
                playlist_id text not null,
                title text not null,
                artist text not null,
                url text not null,
                added_by text not null,
                cover_url text not null,
                position integer not null)
            """)?
        return ok(db)
    }

    // A typed chain over `tracks` for one playlist, ordered by stored position.
    producer loadTracks(db: sqlite.Database, playlistId: String) -> List<Track> {
        binder.useDatabase(db)
        let rows = query.from<TrackRow>("tracks").filter { it.playlist_id == playlistId }.sortedBy { it.position }.collect(provider)
        let tracks = empty List<Track>
        for row in rows { tracks.push(trackFromRow(row)) }
        return tracks
    }

    mapper playlistFromRow(row: PlaylistRow, tracks: List<Track>) -> Playlist {
        return Playlist { found: true, id: row.id, name: row.name, description: row.description, owner: row.owner, tracks: tracks }
    }

    mapper trackFromRow(row: TrackRow) -> Track {
        return Track { id: row.id, title: row.title, artist: row.artist, url: row.url, addedBy: row.added_by, coverUrl: row.cover_url }
    }

    // Builds a positional-parameter array of text values for a bound statement.
    producer strParams(items: List<String>) -> Json {
        let arr = json.array()
        for item in items { arr = json.push(arr, json.str(item)) }
        return arr
    }

    // A case-insensitive LIKE pattern; empty term becomes "%%" (matches all).
    mapper wildcard(term: String) -> String {
        return "%" + text.toLower(term) + "%"
    }

    mapper missingPlaylist(id: String) -> Playlist {
        return Playlist { found: false, id: id, name: "", description: "", owner: "", tracks: empty List<Track> }
    }
}
