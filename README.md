# eXstream

eXstream is a Xi-based music streaming web app with separate services for ingress, auth, file storage, playlists, and the web player.

## Modules

- `api`: Traefik ingress and reverse proxy. Protected routes use a ForwardAuth helper that verifies the bearer JWT and forwards `X-Username` and `X-Role`.
- `auth`: Xi service for registration, login, reset password, token verification, and user profile. Default port: `4001`.
- `playlist`: Xi service for playlist CRUD and music search. Default port: `5001`.
- `file`: Xi file service for create, read, update, delete, and list. Default port: `6001`.
- `web`: React JavaScript music player UI with Tailwind, shadcn-style UI primitives, and Zustand. Default port: `7001`.

## API Specs

- Auth: [`auth/api-spec.yaml`](auth/api-spec.yaml)
- Playlist: [`playlist/api-spec.yaml`](playlist/api-spec.yaml)
- File: [`file/api-spec.yaml`](file/api-spec.yaml)

## Run Locally With Docker

```sh
docker compose up --build
```

- Web UI: http://localhost:7001
- API gateway: http://localhost:8080
- Traefik dashboard: http://localhost:8081
- Auth service: http://localhost:4001
- Playlist service: http://localhost:5001
- File service: http://localhost:6001

Set a shared JWT secret when needed:

```sh
JWT_SECRET="change-me" docker compose up --build
```

The auth service seeds two development users on startup:

| Username | Password | Role | Profile |
| --- | --- | --- | --- |
| `admin` | `admin123` | `ADMIN` | Admin |
| `test` | `test123` | `USER` | Test Listener |

The playlist service seeds initial royalty-free generated music for the `test` user:

| Playlist | Tracks |
| --- | --- |
| Starter Favorites | Midnight Pulse, Glass Harbor, Solar Steps |
| Ambient Loops | Slow Orbit, Clean Room, Open Sky |

Seeded tracks use compact `tone:` URLs that the web player turns into generated WAV audio at playback time.

## Build Xi Services Locally

```sh
xc auth/auth-service.xi
xc playlist/playlist-service.xi
xc file/file-service.xi
```

Run them directly:

```sh
./build/auth-service
./build/playlist-service
./build/file-service
```

Each service accepts an optional port argument.

## Run Web Locally

```sh
cd web
npm install
npm run dev
```

The Vite dev server runs on http://localhost:7001.

Useful web routes:

- `/login`: Login and registration.
- `/`: Music library home.
- `/playlists/:id`: Deep link to a playlist.
- `/search?q=term`: Deep link to music search results.
- `/admin/music`: Admin-only music management.

The web app supports dark mode, mobile-friendly layouts, and PWA installation via its web manifest and service worker.
Admin music management uploads audio through the file service, then stores the uploaded file path on playlist tracks.

## Tests

Run Xi unit tests:

```sh
xi test auth/test/auth_test.xi
xi test playlist/test/playlist_test.xi
xi test file/test/file_test.xi
```

Run JavaScript tests:

```sh
node --test api/test/*.test.js
cd web && npm test
```

Run service smoke tests:

```sh
./scripts/test-services.sh
```

## API Examples

Register:

```sh
curl -X POST http://localhost:8080/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"username":"sia","password":"secret","profileName":"Sia","email":"sia@example.com","avatar":"🎧"}'
```

Create a playlist through the gateway:

```sh
curl -X POST http://localhost:8080/playlists \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Favorites","description":"Daily rotation"}'
```

Direct service calls to protected endpoints must include:

```text
X-Username: sia
X-Role: USER
```
