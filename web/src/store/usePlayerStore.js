import { create } from "zustand";

export const usePlayerStore = create((set) => ({
  token: localStorage.getItem("exstream_token") || "",
  profile: undefined,
  playlists: [],
  selected: undefined,
  nowPlaying: undefined,
  setToken: (token) => {
    localStorage.setItem("exstream_token", token);
    set({ token });
  },
  logout: () => {
    localStorage.removeItem("exstream_token");
    set({ token: "", profile: undefined, playlists: [], selected: undefined, nowPlaying: undefined });
  },
  setProfile: (profile) => set({ profile }),
  setPlaylists: (playlists) => set({ playlists }),
  setSelected: (selected) => set({ selected }),
  setNowPlaying: (nowPlaying) => set({ nowPlaying }),
}));
