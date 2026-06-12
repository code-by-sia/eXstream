import React from "react";
import { cn } from "../lib/utils.js";

const avatars = ["🎧", "🎙️", "🎛️", "🎹", "🥁", "🎸", "🎻", "🎵"];

export function EmojiAvatarSelector() {
  const [selected, setSelected] = React.useState(avatars[0]);

  return (
    <div className="avatar-selector">
      <input type="hidden" name="avatar" value={selected} />
      <span className="avatar-label">Avatar</span>
      <div className="avatar-grid">
        {avatars.map((avatar) => (
          <button
            key={avatar}
            type="button"
            className={cn("avatar-option", selected === avatar ? "avatar-option-active" : "avatar-option-idle")}
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
