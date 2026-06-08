const sampleRate = 8000;
const noteSeconds = 0.45;

function writeString(view, offset, value) {
  for (let i = 0; i < value.length; i += 1) view.setUint8(offset + i, value.charCodeAt(i));
}

function encodeWav(samples) {
  const buffer = new ArrayBuffer(44 + samples.length * 2);
  const view = new DataView(buffer);
  writeString(view, 0, "RIFF");
  view.setUint32(4, 36 + samples.length * 2, true);
  writeString(view, 8, "WAVEfmt ");
  view.setUint32(16, 16, true);
  view.setUint16(20, 1, true);
  view.setUint16(22, 1, true);
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, sampleRate * 2, true);
  view.setUint16(32, 2, true);
  view.setUint16(34, 16, true);
  writeString(view, 36, "data");
  view.setUint32(40, samples.length * 2, true);
  samples.forEach((sample, index) => view.setInt16(44 + index * 2, sample, true));
  return new Uint8Array(buffer);
}

function bytesToBase64(bytes) {
  let binary = "";
  for (let i = 0; i < bytes.length; i += 0x8000) {
    binary += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
  }
  return btoa(binary);
}

export function toneToDataUrl(source) {
  const notes = source.replace("tone:", "").split(",").map(Number).filter(Boolean);
  const samplesPerNote = Math.floor(sampleRate * noteSeconds);
  const samples = [];
  notes.forEach((frequency) => {
    for (let i = 0; i < samplesPerNote; i += 1) {
      const fade = Math.min(i / 400, (samplesPerNote - i) / 400, 1);
      samples.push(Math.round(Math.sin((2 * Math.PI * frequency * i) / sampleRate) * 12000 * fade));
    }
  });
  return `data:audio/wav;base64,${bytesToBase64(encodeWav(samples))}`;
}
