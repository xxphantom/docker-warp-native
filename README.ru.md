# Warp Native in Docker

[🇺🇸 Read in English](README.md)

Docker контейнер для запуска Cloudflare WARP, публикующий WireGuard интерфейс на хост-систему.

## Особенности

- Изолирован в контейнере (требует host mode)
- Минимальный размер образа (~40MB) на базе Alpine Linux
- Очень низкое потребление памяти (всего несколько мегабайт)

## Быстрый старт

### Автоматическая установка

```bash
sudo bash -c "$(curl -sL https://raw.githubusercontent.com/xxphantom/docker-warp-native/main/install.sh)" @ --lang=ru
```

Установщик выполнит:
- Проверку и установку зависимостей (curl, Docker)
- Предложит ввести WARP+ лицензию (опционально)
- Скачает `docker-compose.yml` и запустит контейнер
- Интерактивное меню для управления: обновление, удаление, статус, лицензия

Поддерживаемые ОС: Ubuntu, Debian.

<details>
<summary>Ручная установка с Docker Compose</summary>

```bash
mkdir -p /opt/docker-warp-native
wget https://raw.githubusercontent.com/xxphantom/docker-warp-native/refs/heads/main/docker-compose.yml -O /opt/docker-warp-native/docker-compose.yml
cd /opt/docker-warp-native
docker compose up -d && docker compose logs -f -t
```

**Важно!** С версии 1.1.0 docker-compose.yml, файлы конфигурации будут храниться в директории `/opt/docker-warp-native` после первого запуска.

#### Управление контейнером

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

</details>

## Поддержка WARP+

Контейнер поддерживает WARP+ (премиум-тариф Cloudflare) через переменную окружения `WARP_LICENSE`.

### Через установщик

Запустите установщик и выберите опцию управления лицензией в интерактивном меню.

### Через Docker Compose

Раскомментируйте секцию `environment` в `docker-compose.yml`:

```yaml
    environment:
      - WARP_LICENSE=your-warp-plus-key
```

### Обновление с Free до WARP+

Если у вас уже запущен контейнер с бесплатным WARP, просто добавьте переменную `WARP_LICENSE` и перезапустите контейнер. Контейнер автоматически выполнит повторную регистрацию с WARP+ (Cloudflare требует новую регистрацию для применения лицензии).

### Проверка статуса WARP+

```bash
curl --interface warp https://www.cloudflare.com/cdn-cgi/trace
```

Ищите `warp=plus` в выводе для подтверждения активности WARP+.

## Проверка подключения к WARP

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

- Docker (установщик автоматически устанавливает Docker на Ubuntu/Debian)
- Ядро Linux с поддержкой WireGuard
- Права NET_ADMIN и SYS_MODULE

## Благодарности

Основано на скрипте [warp-native](https://github.com/distillium/warp-native) от distillium. Данный проект контейнеризирует решение для лучшей портативности и изоляции.
Использует [wgcf](https://github.com/ViRb3/wgcf) для генерации конфигурации WARP.

## Лицензия

MIT
