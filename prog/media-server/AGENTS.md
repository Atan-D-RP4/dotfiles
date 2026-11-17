# media-server/ — Personal Media Server in Docker

Complete Docker-based media server: 30+ services across 43 files, managed through docker-compose with a custom compose-file aggregation system.

## Quick Start

```sh
media-server up -d           # start all services (requires env setup)
media-server ps              # list running services
media-server logs -f <svc>   # tail logs
media-server-logs <svc>      # wait for service then tail logs
```

## Architecture

### Service Stack

Services are defined in numbered docker-compose YAML files:

| File | Services | Category |
|------|----------|----------|
| `0001-core.caddy.yml` | **Caddy** reverse proxy | Routing |
| `0002-media.jellyfin.yml` | **Jellyfin** (video) | Media |
| `0002-media.navidrome.yml` | **Navidrome** (music) | Media |
| `0002-media.kavita.yml` | **Kavita** (ebooks/comics) | Media |
| `0003-torrent.*.yml` | **Transmission** / **qBittorrent** | Download clients |
| `0004-indexer.*.yml` | **Sonarr**, **Radarr**, **Lidarr**, **Readarr**, **Bazarr**, **Mylar3**, **Shoko** | Indexers |
| `0005-tracker.prowlarr.yml` | **Prowlarr** (tracker manager) | Tracker |
| `0006-extra.*.yml` | **Flood** (UI), **Heimdall** (dashboard) | Extra |

### Service Ordering
- `00`-`02`: Core infrastructure (Caddy, media servers)
- `03`: Download clients (torrents)
- `04`: Indexers (organize media)
- `05`: Trackers (search providers)
- `06`: Extra UI tools
- `99`: Optional profiles (VPN, auth, metrics, DLNA)

### Compose File Aggregation

`cmds/media-server` is a wrapper that:
1. **Discovers** all `*.yml` files sorted by name
2. **Applies** overrides: if `X.override.yml` exists, it's included
3. **Conditionally** includes optional profiles based on `MEDIA_SERVER_PROFILES`
4. Sources `media-server.env` then optional `media-server.override.env`

Override pattern: `0002-media.jellyfin.override.yml` merges into base config via docker-compose override mechanism.

## Profile System

Profiles are set via `MEDIA_SERVER_PROFILES=profile1,profile2` env var (typically in `$XDG_CONFIG_HOME/media-server/profile.sh`).

| Profile | Enables |
|---------|---------|
| `vpn` | Routes services through gluetun WireGuard container (9999-optional.vpn.yml) |
| `http-proxy` | HTTP proxy service for the VPN network |
| `socks-proxy` | SOCKS5 proxy (requires `vpn` profile) |
| `flaresolverr` | Bypasses Cloudflare protection for trackers |
| `dlna` | Jellyfin in host network mode for DLNA/uPnP |
| `metrics` | Prometheus metrics (requires Prometheus API keys) |
| `flaresolverr` | Cloudflare bypass proxy |

Special env vars:
- `MEDIA_SERVER_AUTHELIA=1` — adds Authelia auth service
- `MEDIA_SERVER_METRICS=1` — adds Prometheus + metrics per service

## Key Environment Variables (`media-server.env`)

```
SITE_ADDRESS=localhost         # Top-level domain for Caddy
TRANSMISSION_PEER_PORT=51413  # Peer port for torrents
QBITTORRENT_PEER_PORT=51413
```

## CLI Commands (linked to `$XDG_BIN_DIR`)

| Command | Purpose |
|---------|---------|
| `media-server` | docker-compose wrapper (cd to dir, compose files, env) |
| `media-server-logs` | Wait for service, then tail logs |
| `tctl` | Transmission CLI helper |
| `qctl` | qBittorrent CLI helper |
| `torvipe` | YAML-based bulk magnet link adder (opens editor) |
| `torwatcher` | Watches download dirs, triggers post-processing |

## Directory Layout

| Path | Purpose |
|------|---------|
| `proxy/` | Caddyfiles (main + `config.d/` for service routes, auth, private) |
| `proxy/local.d/` | Local overrides (gitignored): Caddyfile.global, .snippets, .routes |
| `cmds/` | CLI scripts linked to `$XDG_BIN_DIR` |
| `auto/` | Shell autoloads (`qctl_fzf`, `tctl_fzf`) |
| `tmux/` | tmuxp layout (`media.yml`) |
| `lib/` | Python helpers (torutils, transmission utils, requirements.txt) |
| `transmission/` | Transmission config, scripts, settings |
| `qbittorrent/` | qBittorrent config (categories, settings, scripts) |
| `watcher/` | File-watcher JSON configs (hardlinked into service dirs) |
| `prometheus/` | Prometheus scrape config |
| `Dockerfile.*` | Custom Docker images for jellyfin, qbittorrent, transmission |

## Key Post-Install Steps

1. Set `MEDIA_SERVER_PROFILES` in `$XDG_CONFIG_HOME/media-server/profile.sh`
2. Configure indexers (Sonarr/Radarr/etc.) → add root folders, download clients, metadata
3. Configure Prowlarr → add indexers + sync apps
4. Trust Caddy local CA: `trust anchor --store ~/.config/media-server/caddy/data/caddy/pki/authorities/local/root.crt`
5. (Optional) VPN setup via gluetun + port forwarding
6. (Optional) Authelia via `MEDIA_SERVER_AUTHELIA=1`
7. (Optional) Hard drive RAID/LVM for media storage (see README.org)

## Noteworthy Details

- **Hardlinks**: `watcher/.config.sh` uses `link -Hf` (hardlinks) because container paths need to remain accessible inside Docker
- **Service dirs pre-created** in `.module.sh` to prevent Docker creating them as root
- **Caddy local HTTPS**: auto-generates certs; trust the local CA for browser access
- **Port forwarding**: essential for good torrent seeding performance behind VPN
- **Install**: depends on `../docker/`, `transmission/`, `qbittorrent/`, `watcher/` sub-modules + `packagex jellyfin-media-player mpv-mpris`
