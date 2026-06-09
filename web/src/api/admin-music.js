import { request } from "./client.js";

export function trackFromForm(form, playlist, url) {
  return {
    artist: form.get("artist"),
    playlistId: form.get("playlistId"),
    playlistName: playlist.options[playlist.selectedIndex]?.text || "Selected playlist",
    title: form.get("title"),
    url,
  };
}

export function createLibrarySong(token, track) {
  return request(`/playlists/${track.playlistId}/tracks`, {
    token,
    method: "POST",
    body: JSON.stringify({ title: track.title, artist: track.artist, url: track.url }),
  });
}
