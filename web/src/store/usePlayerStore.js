import { create } from "zustand";

export function trackKey(track) {
  return track ? `${track.playlistId || ""}-${track.id}-${track.url}` : "";
}

export const usePlayerStore = create((set, get) => ({
  token: localStorage.getItem("exstream_token") || "",
  profile: undefined,
  playlists: [],
  selected: undefined,
  nowPlaying: undefined,
  queue: [],
  isPlaying: false,
  repeat: "off",
  setToken: (token) => {
    localStorage.setItem("exstream_token", token);
    set({ token });
  },
  logout: () => {
    localStorage.removeItem("exstream_token");
    set({ token: "", profile: undefined, playlists: [], selected: undefined, nowPlaying: undefined, queue: [], isPlaying: false });
  },
  setProfile: (profile) => set({ profile }),
  setPlaylists: (playlists) => set({ playlists }),
  setSelected: (selected) => set({ selected }),
  setNowPlaying: (nowPlaying, queue) => set({ nowPlaying, queue: queue || (nowPlaying ? [nowPlaying] : []) }),
  setIsPlaying: (isPlaying) => set({ isPlaying }),
  cycleRepeat: () => set((s) => ({ repeat: s.repeat === "off" ? "all" : s.repeat === "all" ? "one" : "off" })),
  playNext: () => {
    const { queue, nowPlaying, repeat } = get();
    const index = queue.findIndex((track) => trackKey(track) === trackKey(nowPlaying));
    if (index >= 0 && index < queue.length - 1) set({ nowPlaying: queue[index + 1] });
    else if (repeat === "all" && queue.length > 0) set({ nowPlaying: { ...queue[0] } });
  },
  playPrevious: () => {
    const { queue, nowPlaying } = get();
    const index = queue.findIndex((track) => trackKey(track) === trackKey(nowPlaying));
    if (index > 0) set({ nowPlaying: queue[index - 1] });
  },
}));

export function isCurrentTrack(nowPlaying, track) {
  return Boolean(track) && trackKey(nowPlaying) === trackKey(track);
}
