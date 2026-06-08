import React from "react";
import { cn } from "../lib/utils.js";

const avatars = ["🎧", "🎙️", "🎛️", "🎹", "🥁", "🎸", "🎻", "🎵"];

export function EmojiAvatarSelector() {
  const [selected, setSelected] = React.useState(avatars[0]);

  return (
    <div className="grid gap-2">
      <input type="hidden" name="avatar" value={selected} />
      <span className="text-xs font-medium text-muted">Avatar</span>
      <div className="grid grid-cols-4 gap-2 sm:grid-cols-8">
        {avatars.map((avatar) => (
          <button
            key={avatar}
            type="button"
            className={cn(
              "grid h-10 place-items-center rounded-md border text-lg transition hover:bg-accent",
              selected === avatar ? "border-foreground bg-accent" : "border-border bg-card"
            )}
            onClick={() => setSelected(avatar)}
            aria-label={`Use ${avatar} avatar`}
          >
            {avatar}
          </button>
        ))}
      </div>
    </div>
  );
}
