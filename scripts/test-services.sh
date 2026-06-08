#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
AUTH_PORT="${AUTH_PORT:-4401}"
PLAYLIST_PORT="${PLAYLIST_PORT:-5501}"
FILE_PORT="${FILE_PORT:-6601}"
RUN_ID="${RUN_ID:-$$}"

cd "$ROOT"

xc auth/auth-service.xi
xc playlist/playlist-service.xi
xc file/file-service.xi

./build/auth-service "$AUTH_PORT" &
AUTH_PID="$!"
./build/playlist-service "$PLAYLIST_PORT" &
PLAYLIST_PID="$!"
./build/file-service "$FILE_PORT" &
FILE_PID="$!"

cleanup() {
  kill "$AUTH_PID" "$PLAYLIST_PID" "$FILE_PID" 2>/dev/null || true
}
trap cleanup EXIT

sleep 1

expect_status() {
  label="$1"
  expected="$2"
  shift 2
  actual="$(curl -s -o /tmp/exstream-test-response -w '%{http_code}' "$@")"
  if [ "$actual" != "$expected" ]; then
    echo "$label expected $expected but got $actual" >&2
    cat /tmp/exstream-test-response >&2
    exit 1
  fi
}

expect_status "admin login" 200 \
  -X POST "http://127.0.0.1:$AUTH_PORT/auth/login" \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123"}'

expect_status "test login" 200 \
  -X POST "http://127.0.0.1:$AUTH_PORT/auth/login" \
  -H 'Content-Type: application/json' \
  -d '{"username":"test","password":"test123"}'

expect_status "registration ignores admin role" 200 \
  -X POST "http://127.0.0.1:$AUTH_PORT/auth/register" \
  -H 'Content-Type: application/json' \
  -d "{\"username\":\"register-user-$RUN_ID\",\"password\":\"secret\",\"profileName\":\"Smoke User\",\"email\":\"smoke-$RUN_ID@exstream.local\",\"avatar\":\"🎧\",\"role\":\"ADMIN\"}"

if ! grep -q '"role":"USER"' /tmp/exstream-test-response; then
  echo "registration should always create USER accounts" >&2
  cat /tmp/exstream-test-response >&2
  exit 1
fi

expect_status "file rejects missing headers" 403 \
  "http://127.0.0.1:$FILE_PORT/files"

expect_status "file upload returns unique link" 200 \
  -X POST "http://127.0.0.1:$FILE_PORT/file" \
  -H 'Content-Type: text/plain' \
  -H 'X-Username: admin' \
  -H 'X-Role: ADMIN' \
  -d 'data:audio/plain;base64,ZmFrZQ=='

if ! grep -q '"/file/music/' /tmp/exstream-test-response; then
  echo "file upload should return a /file/music/<uuid> link" >&2
  cat /tmp/exstream-test-response >&2
  exit 1
fi

expect_status "playlist rejects missing headers" 403 \
  "http://127.0.0.1:$PLAYLIST_PORT/playlists"

expect_status "playlist accepts identity headers" 200 \
  -X POST "http://127.0.0.1:$PLAYLIST_PORT/playlists" \
  -H 'Content-Type: application/json' \
  -H 'X-Username: test' \
  -H 'X-Role: USER' \
  -d '{"name":"Smoke","description":"service test"}'

expect_status "playlist exposes starter music" 200 \
  "http://127.0.0.1:$PLAYLIST_PORT/playlists" \
  -H 'X-Username: test' \
  -H 'X-Role: USER'

if ! grep -q 'Starter Favorites' /tmp/exstream-test-response; then
  echo "starter playlist should be seeded for the test user" >&2
  cat /tmp/exstream-test-response >&2
  exit 1
fi

echo "service smoke tests passed"
