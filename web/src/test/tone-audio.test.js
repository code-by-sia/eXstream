import assert from "node:assert/strict";
import { test } from "node:test";
import { toneToDataUrl } from "../api/tone-audio.js";

test("generates a wav data url for seeded tone tracks", () => {
  const url = toneToDataUrl("tone:220,330");
  const encoded = url.replace("data:audio/wav;base64,", "");
  const wav = Buffer.from(encoded, "base64").toString("ascii", 0, 4);

  assert.match(url, /^data:audio\/wav;base64,/);
  assert.equal(wav, "RIFF");
});
