# Warp Native in Docker

[🇺🇸 Read in English](README.md)

Docker контейнер для запуска Cloudflare WARP, публикующий WireGuard интерфейс на хост-систему.

## Особенности

- Изолирован в контейнере (требует host mode)
- Минимальный размер образа (~40MB) на базе Alpine Linux
- Очень низкое потребление памяти (всего несколько мегабайт)

## Быстрый старт

### Установка Docker (если не установлен)

Следуйте официальным инструкциям:

- [Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)

## Запуск возможен в двух вариантах (вариант docker compose рекомендуется):

### 1. Первичный запуск с помощью Docker Compose (требуется на каждой ноде)

```bash
mkdir -p /opt/docker-warp-native
wget https://raw.githubusercontent.com/xxphantom/docker-warp-native/refs/heads/main/docker-compose.yml -O /opt/docker-warp-native/docker-compose.yml
cd /opt/docker-warp-native
docker compose up -d && docker compose logs -f -t
```

### Управление контейнером (вариант docker compose)

```bash
# Перейти в директорию с docker-compose.yml
cd /opt/docker-warp-native

# Запустить контейнер
docker compose up -d && docker compose logs -f -t

# Посмотреть логи
docker compose logs -f -t

# Остановить контейнер
docker compose down

# Перезапустить контейнер
docker compose down && docker compose up -d && docker compose logs -f -t

# Обновить контейнер
docker compose pull && docker compose down && docker compose up -d && docker compose logs -f -t
```

### 2. Первичный запуск с помощью Docker CLI (требуется на каждой ноде)

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

### Управление контейнером (вариант запуска docker run)

```bash
# Запустить контейнер
docker run -d \
  --name warp-native \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  -v warp-config:/etc/wireguard \
  -v /lib/modules:/lib/modules:ro \
  --restart always \
  ghcr.io/xxphantom/docker-warp-native:latest

# Посмотреть логи
docker logs -f -t warp-native

# Остановить контейнер
docker stop warp-native

# Перезапустить контейнер
docker restart warp-native

# Обновить контейнер
docker pull ghcr.io/xxphantom/docker-warp-native:latest && docker stop warp-native && docker rm warp-native && docker run -d \
  --name warp-native \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  -v warp-config:/etc/wireguard \
  -v /lib/modules:/lib/modules:ro \
  --restart always \
  ghcr.io/xxphantom/docker-warp-native:latest
```

### Проверка подключения к WARP

```bash
curl --interface warp https://ipinfo.io
```

Должно показать примерно следующее:

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

## Использование

После запуска контейнера, WARP интерфейс будет доступен на хост-системе. Вы можете направлять трафик через него в Xray конфигурации.

## Шаблоны для конфигурации Xray

<details>
  <summary>📝 Показать пример outbound</summary>

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
  <summary>📝 Показать пример routing rule</summary>

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

- `/etc/wireguard` - директория с конфигурацией WARP (warp.conf и wgcf-account.toml)
- `/lib/modules` - модули ядра (требуется для WireGuard)

## Требования

- Docker
- Ядро Linux с поддержкой WireGuard
- Права NET_ADMIN и SYS_MODULE

## Благодарности

Основано на скрипте [warp-native](https://github.com/distillium/warp-native) от distillium. Данный проект контейнеризирует решение для лучшей портативности и изоляции.
Использует [wgcf](https://github.com/ViRb3/wgcf) для генерации конфигурации WARP.

## Лицензия

MIT
