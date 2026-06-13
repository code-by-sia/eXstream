import { request } from "./client.js";

export function createLibrarySong(token, track) {
  return addTrackToPlaylist(token, track.playlistId, track);
}

// Adds a track (new or existing) to a playlist. Used for song creation, for
// putting a song into multiple playlists, and as the first half of a move.
export function addTrackToPlaylist(token, playlistId, track) {
  return request(`/playlists/${playlistId}/tracks`, {
    token,
    method: "POST",
    body: JSON.stringify({ title: track.title, artist: track.artist, url: track.url, coverUrl: track.coverUrl || "" }),
  });
}

// Adds the track to the target playlist, then removes it from its current one.
export async function moveTrackToPlaylist(token, targetPlaylistId, track) {
  await addTrackToPlaylist(token, targetPlaylistId, track);
  await deleteLibrarySong(token, track);
}

export function updateLibrarySong(token, track) {
  return request(`/playlists/${track.playlistId}/tracks/${track.id}`, {
    token,
    method: "PUT",
    body: JSON.stringify({ title: track.title, artist: track.artist, url: track.url, coverUrl: track.coverUrl || "" }),
  });
}

export function deleteLibrarySong(token, track) {
  return request(`/playlists/${track.playlistId}/tracks/${track.id}`, { token, method: "DELETE" });
}
