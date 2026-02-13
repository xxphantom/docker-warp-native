# Warp Native in Docker

[🇷🇺 Читать на русском](README.ru.md)

Docker container for running Cloudflare WARP, publishing WireGuard interface to the host system.

## Features

- Isolated in container (host network mode required)
- Minimal image size (~40MB) based on Alpine Linux
- Very low memory usage (just a few megabytes)

## Quick Start

### Automatic Installation

```bash
sudo bash -c "$(curl -sL https://raw.githubusercontent.com/xxphantom/docker-warp-native/main/install.sh)"
```

The installer will:
- Check and install dependencies (curl, Docker)
- Offer to enter a WARP+ license (optional)
- Download `docker-compose.yml` and start the container
- Provide an interactive menu for management: update, remove, status, license

Supported OS: Ubuntu, Debian.

<details>
<summary>Manual Setup with Docker Compose</summary>

```bash
mkdir -p /opt/docker-warp-native
wget https://raw.githubusercontent.com/xxphantom/docker-warp-native/refs/heads/main/docker-compose.yml -O /opt/docker-warp-native/docker-compose.yml
cd /opt/docker-warp-native
docker compose up -d && docker compose logs -f -t
```

**Important:** Since version 1.1.0 docker-compose.yml, configuration files will be stored in `/opt/docker-warp-native` directory after initial launch.

#### Container Management

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
docker compose down && docker compose up -d && docker compose logs -f -t

# Update container
docker compose pull && docker compose down && docker compose up -d && docker compose logs -f -t
```

</details>

## WARP+ Support

The container supports WARP+ (Cloudflare's premium tier) via the `WARP_LICENSE` environment variable.

### Using the Installer

Run the installer and select the license management option from the interactive menu.

### Using Docker Compose

Uncomment the `environment` section in `docker-compose.yml`:

```yaml
    environment:
      - WARP_LICENSE=your-warp-plus-key
```

### Upgrading from Free to WARP+

If you already have a running free WARP container, simply add the `WARP_LICENSE` variable and restart the container. The container will automatically re-register with WARP+ (Cloudflare requires a new registration to apply a license).

### Verifying WARP+ Status

```bash
curl --interface warp https://www.cloudflare.com/cdn-cgi/trace
```

Look for `warp=plus` in the output to confirm WARP+ is active.

## Verify WARP Connection

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

- Docker (the installer automatically installs Docker on Ubuntu/Debian)
- Linux kernel with WireGuard support
- NET_ADMIN and SYS_MODULE capabilities

## Credits

Based on the [warp-native](https://github.com/distillium/warp-native) script by distillium. This project containerizes the solution for better portability and isolation.
Uses [wgcf](https://github.com/ViRb3/wgcf) to generate WARP configuration.

## License

MIT
