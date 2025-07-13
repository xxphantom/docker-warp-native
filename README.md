# Warp Native in Docker

[🇷🇺 Читать на русском](README.ru.md)

Docker container for running Cloudflare WARP in host mode, publishing WireGuard interface to the host system.

📖 **[How it works](HOW-IT-WORKS.md)** - architecture, internals, troubleshooting

## Features

- Works in host network mode
- Isolated in container and does not affect the host system
- Minimal image size (~40MB) based on Alpine Linux 3.22
- Very low memory usage (just a few megabytes)

## Quick Start

### Install Docker (if not installed)

Follow the official instructions:

- [Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)

Launch is possible in two ways:

### 1. Launch using Docker Compose (required on each node)

```bash
mkdir -p /opt/docker-warp-native
wget https://raw.githubusercontent.com/xxphantom/docker-warp-native/refs/heads/main/docker-compose.yml -O /opt/docker-warp-native/docker-compose.yml
cd /opt/docker-warp-native
docker compose up -d && docker compose logs -f -t
```

### 2. Launch using Docker CLI (required on each node)

```bash
docker volume create warp-config

docker run -d \
  --name warp-native \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  -v warp-config:/etc/wireguard \
  -v /lib/modules:/lib/modules:ro \
  --restart always \
  ghcr.io/xxphantom/docker-warp-native:latest
```

### Verify WARP connection

```bash
curl --interface warp https://ipinfo.io
```

Should display something like:

```json
{
  "ip": "111.222.333.444",
  "city": "Amsterdam",
  "region": "North Holland",
  "country": "NL",
  "loc": "52.3740,4.8897",
  "org": "AS13335 Cloudflare, Inc.",
  "postal": "1012",
  "timezone": "Europe/Amsterdam",
  "readme": "https://ipinfo.io/missingauth"
}
```

### Container Management

```bash
# Go to directory with docker-compose.yml
cd /opt/docker-warp-native

# Start container
docker compose up -d && docker compose logs -f -t

# View logs
docker compose logs -f -t

# Stop container
docker compose down

# Restart container
docker compose restart

# Update container
docker compose pull && docker compose up -d --force-recreate
```

## Usage

After starting the container, WARP interface will be available on the host system. You can route traffic through it in Xray configuration.

## Templates for Xray Configuration

<details>
  <summary>📝 Show outbound example</summary>

```json
{
  "tag": "warp-out",
  "protocol": "freedom",
  "settings": {},
  "streamSettings": {
    "sockopt": {
      "interface": "warp",
      "tcpFastOpen": true
    }
  }
}
```

</details>

<details>
  <summary>📝 Show routing rule example</summary>

```json
{
  "type": "field",
  "domain": [
    "netflix.com",
    "youtube.com",
    "twitter.com",
  ],
  "inboundTag": [
    "Node-1",
    "Node-2"
  ],
  "outboundTag": "warp-out"
},
{
  "type": "field",
  "user": [
    "username-warp-all"
  ],
  "outboundTag": "warp-out"
}

```

</details>

## Volumes

- `/etc/wireguard` - WARP configuration directory (warp.conf and wgcf-account.toml)
- `/lib/modules` - kernel modules (required for WireGuard)

## Requirements

- Docker
- Linux kernel with WireGuard support
- NET_ADMIN and SYS_MODULE capabilities

## Credits

Based on the [warp-native](https://github.com/distillium/warp-native) script by distillium. This project containerizes the solution for better portability and isolation.
Uses [wgcf](https://github.com/ViRb3/wgcf) to generate WARP configuration.

## License

MIT
