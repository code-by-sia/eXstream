import "std/crypto.xi"
import "std/json.xi"
import "std/query.xi"
import "std/text.xi"

// Flat rows matching the table columns so the QueryProvider can hydrate them
// directly (field names == column names).
type PlaylistRow = { id: String, name: String, description: String, owner: String }
type TrackRow = { id: String, playlist_id: String, title: String, artist: String, url: String, added_by: String, cover_url: String, position: Integer }
// A track joined to its playlist's owner — an internal projection used only to
// filter searchTracks by ownership before shaping the public MusicHit.
type SearchHitRow = { id: String, playlist_id: String, title: String, artist: String, url: String, added_by: String, cover_url: String, owner: String }

class SqlitePlaylistRepository implements PlaylistRepository {
    deps { sql: sqlite.SQLite, dbPaths: DatabasePaths, provider: QueryProvider, binder: DatabaseBinder }

    producer get(id: String) -> Playlist {
        let opened = connect()
        if isErr(opened) { return missingPlaylist(id) }
        let db = opened.value

        binder.useDatabase(db)
        let rows = query.from<PlaylistRow>("playlists")
            .filter { it.id == id }
            .collect(provider)
        if rows.isEmpty() { sql.close(db) return missingPlaylist(id) }

        let playlist = playlistFromRow(rows.get(0), loadTracks(id))
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
            rows = query.from<PlaylistRow>("playlists")
                .sortedBy { it.name }
                .collect(provider)
        } else {
            rows = query.from<PlaylistRow>("playlists")
                .filter { it.owner == username }
                .sortedBy { it.name }
                .collect(provider)
        }
        for row in rows { result.push(playlistFromRow(row, loadTracks(row.id))) }
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
                .sortedBy { it.name }
                .collect(provider)
        } else {
            rows = query.from<PlaylistRow>("playlists")
                .filter { it.owner == username and (it.name.lowercase().contains(needle) or it.description.lowercase().contains(needle)) }
                .sortedBy { it.name }
                .collect(provider)
        }
        for row in rows { result.push(playlistFromRow(row, loadTracks(row.id))) }
        sql.close(db)
        return result
    }

    // Cross-table search: a typed .join() over tracks/playlists (for the owner
    // check), projected to MusicHit, then filtered/sorted like any other query
    // chain — no raw SQL.
    producer searchTracks(term: String, username: String, role: String) -> List<MusicHit> {
        let opened = connect()
        if isErr(opened) { return empty List<MusicHit> }
        let db = opened.value
        binder.useDatabase(db)

        let needle = text.toLower(term)
        let joined = query.from<TrackRow>("tracks")
            .join(query.from<PlaylistRow>("playlists"), { it.playlist_id }, { it.id })
            .map { SearchHitRow {
                id: it.first.id, playlist_id: it.first.playlist_id, title: it.first.title,
                artist: it.first.artist, url: it.first.url, added_by: it.first.added_by,
                cover_url: it.first.cover_url, owner: it.second.owner
            } }
            .filter { it.title.lowercase().contains(needle) or it.artist.lowercase().contains(needle) }

        let rows = empty List<SearchHitRow>
        if role == "ADMIN" {
            rows = joined.collect(provider)
        } else {
            rows = joined.filter { it.owner == username }.collect(provider)
        }
        sql.close(db)

        let hits = empty List<MusicHit>
        for row in rows {
            hits.push(MusicHit { id: row.id, playlistId: row.playlist_id, title: row.title, artist: row.artist, url: row.url, addedBy: row.added_by, coverUrl: row.cover_url })
        }
        return hits
    }

    producer create(name: String, description: String, owner: String) -> String {
        let opened = connect()
        if isErr(opened) { return "" }
        let db = opened.value
        binder.useDatabase(db)

        let id = crypto.randomHex(8)
        provider.insert("playlists", PlaylistRow { id: id, name: name, description: description, owner: owner } as Json)
        sql.close(db)
        return id
    }

    producer remove(id: String) -> Bool {
        let opened = connect()
        if isErr(opened) { return false }
        let db = opened.value
        binder.useDatabase(db)

        provider.remove("tracks", "playlist_id", id as Json)
        provider.remove("playlists", "id", id as Json)
        sql.close(db)
        return true
    }

    producer addTrack(id: String, title: String, artist: String, url: String, addedBy: String, coverUrl: String) -> String {
        let opened = connect()
        if isErr(opened) { return "" }
        let db = opened.value
        binder.useDatabase(db)

        let trackId = crypto.randomHex(8)
        let position = tracksIn(id).len()
        provider.insert("tracks", TrackRow { id: trackId, playlist_id: id, title: title, artist: artist, url: url, added_by: addedBy, cover_url: coverUrl, position: position } as Json)
        sql.close(db)
        return trackId
    }

    producer updateTrack(id: String, trackId: String, title: String, artist: String, url: String, coverUrl: String) -> String {
        let opened = connect()
        if isErr(opened) { return "storage-failed" }
        let db = opened.value
        binder.useDatabase(db)

        let existing = trackById(trackId)
        if let row = existing {
            if row.playlist_id != id { sql.close(db) return "not-found" }
            provider.insert("tracks", TrackRow { id: row.id, playlist_id: row.playlist_id, title: title, artist: artist, url: url, added_by: row.added_by, cover_url: coverUrl, position: row.position } as Json)
            sql.close(db)
            return "updated"
        }
        sql.close(db)
        return "not-found"
    }

    producer deleteTrack(id: String, trackId: String) -> String {
        let opened = connect()
        if isErr(opened) { return "storage-failed" }
        let db = opened.value
        binder.useDatabase(db)

        let existing = trackById(trackId)
        if let row = existing {
            if row.playlist_id != id { sql.close(db) return "not-found" }
            provider.remove("tracks", "id", trackId as Json)
            sql.close(db)
            return "deleted"
        }
        sql.close(db)
        return "not-found"
    }

    // Moves a track to another playlist atomically: fetch, reassign
    // playlist_id, and append it to the target's order via a full-row upsert.
    // The track keeps its id, so there is no add-then-delete duplication window.
    producer moveTrack(id: String, trackId: String, targetId: String) -> String {
        let opened = connect()
        if isErr(opened) { return "storage-failed" }
        let db = opened.value
        binder.useDatabase(db)

        let existing = trackById(trackId)
        if let row = existing {
            if row.playlist_id != id { sql.close(db) return "not-found" }
            let position = tracksIn(targetId).len()
            provider.insert("tracks", TrackRow { id: row.id, playlist_id: targetId, title: row.title, artist: row.artist, url: row.url, added_by: row.added_by, cover_url: row.cover_url, position: position } as Json)
            sql.close(db)
            return "moved"
        }
        sql.close(db)
        return "not-found"
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
    // Assumes the connection is already bound (every caller binds it first).
    producer loadTracks(playlistId: String) -> List<Track> {
        let rows = query.from<TrackRow>("tracks")
            .filter { it.playlist_id == playlistId }
            .sortedBy { it.position }
            .collect(provider)
        let tracks = empty List<Track>
        for row in rows { tracks.push(trackFromRow(row)) }
        return tracks
    }

    producer tracksIn(playlistId: String) -> List<TrackRow> {
        return query.from<TrackRow>("tracks").filter { it.playlist_id == playlistId }.collect(provider)
    }

    producer trackById(trackId: String) -> TrackRow? {
        return query.from<TrackRow>("tracks").filter { it.id == trackId }.first(provider)
    }

    mapper playlistFromRow(row: PlaylistRow, tracks: List<Track>) -> Playlist {
        return Playlist { found: true, id: row.id, name: row.name, description: row.description, owner: row.owner, tracks: tracks }
    }

    mapper trackFromRow(row: TrackRow) -> Track {
        return Track { id: row.id, title: row.title, artist: row.artist, url: row.url, addedBy: row.added_by, coverUrl: row.cover_url }
    }

    mapper missingPlaylist(id: String) -> Playlist {
        return Playlist { found: false, id: id, name: "", description: "", owner: "", tracks: empty List<Track> }
    }
}
