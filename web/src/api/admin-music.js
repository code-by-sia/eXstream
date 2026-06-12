import { request } from "./client.js";

export function trackFromUpload(form, playlist, url, metadata) {
  return {
    artist: metadata.artist || "",
    coverUrl: metadata.coverUrl || "",
    playlistId: form.get("playlistId"),
    playlistName: playlist.options[playlist.selectedIndex]?.text || "Selected playlist",
    title: metadata.title,
    url,
  };
}

export function createLibrarySong(token, track) {
  return request(`/playlists/${track.playlistId}/tracks`, {
    token,
    method: "POST",
    body: JSON.stringify({ title: track.title, artist: track.artist, url: track.url, coverUrl: track.coverUrl || "" }),
  });
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
