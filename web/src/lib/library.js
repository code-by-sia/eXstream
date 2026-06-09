export function allTracks(playlists) {
  return playlists.flatMap((playlist) =>
    playlist.tracks.map((track) => ({
      ...track,
      playlistId: playlist.id,
      playlistName: playlist.name,
    }))
  );
}

export function featuredTrack(playlists) {
  return allTracks(playlists)[0];
}

export function playlistCards(playlists) {
  return playlists.map((playlist) => ({
    ...playlist,
    coverTrack: playlist.tracks[0],
    subtitle: `${playlist.tracks.length} tracks · ${playlist.owner}`,
  }));
}

export function playlistById(playlists, id) {
  return playlists.find((playlist) => playlist.id === id);
}

export function artistGroups(playlists) {
  const groups = new Map();
  allTracks(playlists).forEach((track) => {
    const name = track.artist || "Unknown Artist";
    const current = groups.get(name) || { id: name, name, tracks: [] };
    current.tracks.push(track);
    groups.set(name, current);
  });
  return Array.from(groups.values()).sort((a, b) => a.name.localeCompare(b.name));
}

export function pageCopy(pathname) {
  const copy = {
    "/": ["Listen Now", "Top picks from your library, ready for the next play."],
    "/browse": ["Browse", "Explore every playlist and track in eXstream."],
    "/radio": ["Radio", "Lean-back stations generated from your saved music."],
    "/library/playlists": ["Playlists", "Collections you can open, share, and keep building."],
    "/library/songs": ["Songs", "Every track in your streaming library."],
    "/made-for-you": ["Made for You", "Personal mixes built from your playlists."],
    "/artists": ["Artists", "Browse the people behind your tracks."],
    "/albums": ["Albums", "Playlist albums and saved collections."],
    "/search": ["Search", "Find music, artists, and playlists."],
  };
  return copy[pathname] || ["Playlist", "Saved music from your library."];
}
