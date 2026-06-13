// Encodes a raw string as a JSON string literal (quoted and escaped).
// Implemented by JsonTextEncoder; injected wherever JSON is hand-rendered.
interface JsonText {
    mapper encode(s: String) -> String
}
