# Warp Native in Docker

[🇺🇸 Read in English](README.md)

Docker контейнер для запуска Cloudflare WARP в режиме host, публикующий WireGuard интерфейс на хост-систему.

📖 **[Как это работает](HOW-IT-WORKS.ru.md)** - архитектура, принцип работы, устранение проблем

## Особенности

- Работает в host network режиме
- Изолирован в контейнере и не влияет на хост-систему
- Минимальный размер образа (~40MB) на базе Alpine Linux 3.22
- Очень низкое потребление памяти (всего несколько мегабайт)

## Быстрый старт

### Установка Docker (если не установлен)

Следуйте официальным инструкциям:

- [Docker](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)

Запуск возможен в двух вариантах:

### 1. Запуск с помощью Docker Compose (требуется на каждой ноде)

```bash
mkdir -p /opt/docker-warp-native
wget https://raw.githubusercontent.com/xxphantom/docker-warp-native/refs/heads/main/docker-compose.yml -O /opt/docker-warp-native/docker-compose.yml
cd /opt/docker-warp-native
docker compose up -d && docker compose logs -f -t
```

### 2. Запуск с помощью Docker CLI (требуется на каждой ноде)

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

### Управление контейнером

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
docker compose restart

# Обновить контейнер
docker compose pull && docker compose up -d --force-recreate
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
