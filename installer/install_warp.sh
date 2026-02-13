#!/bin/bash
#
# Docker WARP Native — Installer
# https://github.com/xxphantom/docker-warp-native
#

set -euo pipefail

# ─── Constants ───────────────────────────────────────────────────────────────

WARP_DIR="/opt/docker-warp-native"
COMPOSE_FILE="$WARP_DIR/docker-compose.yml"
IMAGE="ghcr.io/xxphantom/docker-warp-native:latest"
COMPOSE_URL="https://raw.githubusercontent.com/xxphantom/docker-warp-native/main/docker-compose.yml"
CONTAINER_NAME="warp-native"

# ─── Colors ──────────────────────────────────────────────────────────────────

BOLD_GREEN='\033[1;32m'
BOLD_RED='\033[1;31m'
BOLD_YELLOW='\033[1;33m'
BOLD_BLUE='\033[1;34m'
BOLD_CYAN='\033[1;96m'
BOLD_WHITE='\033[1;97m'
DIM='\033[2m'
NC='\033[0m'

# ─── Language ────────────────────────────────────────────────────────────────

LANG_CHOICE="en"

declare -A LANG_EN
declare -A LANG_RU

# --- General ---
LANG_EN[title]="Docker WARP Native"
LANG_RU[title]="Docker WARP Native"

LANG_EN[subtitle]="Cloudflare WARP in Docker Container"
LANG_RU[subtitle]="Cloudflare WARP в Docker-контейнере"

LANG_EN[select_action]="Select action"
LANG_RU[select_action]="Выберите действие"

LANG_EN[your_choice]="Your choice"
LANG_RU[your_choice]="Ваш выбор"

LANG_EN[invalid_choice]="Invalid choice. Please try again."
LANG_RU[invalid_choice]="Неверный выбор. Попробуйте снова."

LANG_EN[press_enter]="Press Enter to return to menu..."
LANG_RU[press_enter]="Нажмите Enter для возврата в меню..."

LANG_EN[yes_no_y]="y"
LANG_RU[yes_no_y]="y"

LANG_EN[yes_no_n]="n"
LANG_RU[yes_no_n]="n"

LANG_EN[yes_no_prompt]="(y/n)"
LANG_RU[yes_no_prompt]="(y/n)"

# --- Menu items ---
LANG_EN[menu_install]="Install WARP"
LANG_RU[menu_install]="Установить WARP"

LANG_EN[menu_uninstall]="Uninstall WARP"
LANG_RU[menu_uninstall]="Удалить WARP"

LANG_EN[menu_update]="Update WARP"
LANG_RU[menu_update]="Обновить WARP"

LANG_EN[menu_status]="Status & Logs"
LANG_RU[menu_status]="Статус и логи"

LANG_EN[menu_license]="Configure WARP+ License"
LANG_RU[menu_license]="Настроить лицензию WARP+"

LANG_EN[menu_exit]="Exit"
LANG_RU[menu_exit]="Выход"

# --- Root check ---
LANG_EN[error_root]="This script must be run as root (use sudo)"
LANG_RU[error_root]="Скрипт должен быть запущен от root (используйте sudo)"

# --- Distro check ---
LANG_EN[error_distro]="Unsupported distribution. Only Ubuntu and Debian are supported."
LANG_RU[error_distro]="Неподдерживаемый дистрибутив. Поддерживаются только Ubuntu и Debian."

LANG_EN[detected_distro]="Detected"
LANG_RU[detected_distro]="Обнаружена ОС"

# --- Dependencies ---
LANG_EN[installing_deps]="Installing dependencies..."
LANG_RU[installing_deps]="Установка зависимостей..."

LANG_EN[deps_installed]="Dependencies installed"
LANG_RU[deps_installed]="Зависимости установлены"

# --- Docker ---
LANG_EN[docker_found]="Docker is already installed"
LANG_RU[docker_found]="Docker уже установлен"

LANG_EN[docker_not_found]="Docker not found"
LANG_RU[docker_not_found]="Docker не найден"

LANG_EN[install_docker_prompt]="Docker is required. Install Docker now?"
LANG_RU[install_docker_prompt]="Требуется Docker. Установить Docker сейчас?"

LANG_EN[installing_docker]="Installing Docker..."
LANG_RU[installing_docker]="Установка Docker..."

LANG_EN[docker_installed]="Docker installed successfully"
LANG_RU[docker_installed]="Docker успешно установлен"

LANG_EN[docker_install_failed]="Failed to install Docker"
LANG_RU[docker_install_failed]="Не удалось установить Docker"

LANG_EN[docker_declined]="Docker installation declined. Cannot continue."
LANG_RU[docker_declined]="Установка Docker отклонена. Невозможно продолжить."

LANG_EN[compose_not_found]="Docker Compose plugin not found"
LANG_RU[compose_not_found]="Плагин Docker Compose не найден"

# --- Install ---
LANG_EN[already_installed]="WARP is already installed at"
LANG_RU[already_installed]="WARP уже установлен в"

LANG_EN[reinstall_prompt]="Reinstall? This will recreate the container (config is preserved)."
LANG_RU[reinstall_prompt]="Переустановить? Контейнер будет пересоздан (конфигурация сохранится)."

LANG_EN[install_cancelled]="Installation cancelled."
LANG_RU[install_cancelled]="Установка отменена."

LANG_EN[creating_dir]="Creating directory"
LANG_RU[creating_dir]="Создание директории"

LANG_EN[license_prompt]="Enter WARP+ license key (leave empty for free WARP)"
LANG_RU[license_prompt]="Введите ключ лицензии WARP+ (оставьте пустым для бесплатного WARP)"

LANG_EN[license_set]="WARP+ license configured"
LANG_RU[license_set]="Лицензия WARP+ настроена"

LANG_EN[using_free]="Using free WARP"
LANG_RU[using_free]="Используется бесплатный WARP"

LANG_EN[downloading_compose]="Downloading docker-compose.yml..."
LANG_RU[downloading_compose]="Скачивание docker-compose.yml..."

LANG_EN[download_failed]="Failed to download docker-compose.yml"
LANG_RU[download_failed]="Не удалось скачать docker-compose.yml"

LANG_EN[starting_container]="Starting WARP container..."
LANG_RU[starting_container]="Запуск контейнера WARP..."

LANG_EN[container_started]="WARP container started"
LANG_RU[container_started]="Контейнер WARP запущен"

LANG_EN[start_failed]="Failed to start container"
LANG_RU[start_failed]="Не удалось запустить контейнер"

LANG_EN[install_complete]="Installation complete!"
LANG_RU[install_complete]="Установка завершена!"

LANG_EN[show_logs_prompt]="Show container logs?"
LANG_RU[show_logs_prompt]="Показать логи контейнера?"

LANG_EN[verify_hint]="Verify with: curl --interface warp https://ipinfo.io"
LANG_RU[verify_hint]="Проверка: curl --interface warp https://ipinfo.io"

# --- Uninstall ---
LANG_EN[not_installed]="WARP is not installed (directory not found)"
LANG_RU[not_installed]="WARP не установлен (директория не найдена)"

LANG_EN[stopping_container]="Stopping WARP container..."
LANG_RU[stopping_container]="Остановка контейнера WARP..."

LANG_EN[container_stopped]="Container stopped"
LANG_RU[container_stopped]="Контейнер остановлен"

LANG_EN[remove_config_prompt]="Remove configuration and data directory"
LANG_RU[remove_config_prompt]="Удалить конфигурацию и директорию данных"

LANG_EN[config_removed]="Configuration removed"
LANG_RU[config_removed]="Конфигурация удалена"

LANG_EN[config_kept]="Configuration preserved at"
LANG_RU[config_kept]="Конфигурация сохранена в"

LANG_EN[uninstall_complete]="WARP has been uninstalled"
LANG_RU[uninstall_complete]="WARP удалён"

# --- Update ---
LANG_EN[pulling_image]="Pulling latest image..."
LANG_RU[pulling_image]="Скачивание последнего образа..."

LANG_EN[image_pulled]="Image updated"
LANG_RU[image_pulled]="Образ обновлён"

LANG_EN[pull_failed]="Failed to pull image"
LANG_RU[pull_failed]="Не удалось скачать образ"

LANG_EN[recreating_container]="Recreating container..."
LANG_RU[recreating_container]="Пересоздание контейнера..."

LANG_EN[update_complete]="WARP updated successfully"
LANG_RU[update_complete]="WARP успешно обновлён"

# --- Status ---
LANG_EN[status_header]="WARP Status"
LANG_RU[status_header]="Статус WARP"

LANG_EN[container_status]="Container status"
LANG_RU[container_status]="Статус контейнера"

LANG_EN[recent_logs]="Recent logs"
LANG_RU[recent_logs]="Последние логи"

LANG_EN[connection_check]="Connection check"
LANG_RU[connection_check]="Проверка соединения"

LANG_EN[warp_not_running]="WARP interface is not available (container may not be running)"
LANG_RU[warp_not_running]="Интерфейс WARP недоступен (контейнер может быть не запущен)"

# --- License ---
LANG_EN[current_compose]="Current docker-compose.yml"
LANG_RU[current_compose]="Текущий docker-compose.yml"

LANG_EN[enter_license]="Enter WARP+ license key"
LANG_RU[enter_license]="Введите ключ лицензии WARP+"

LANG_EN[license_empty]="License key cannot be empty"
LANG_RU[license_empty]="Ключ лицензии не может быть пустым"

LANG_EN[license_updated]="License updated in docker-compose.yml"
LANG_RU[license_updated]="Лицензия обновлена в docker-compose.yml"

LANG_EN[license_restart_prompt]="Recreate container to apply the new license? Existing config will be removed for re-registration."
LANG_RU[license_restart_prompt]="Пересоздать контейнер для применения новой лицензии? Существующая конфигурация будет удалена для перерегистрации."

LANG_EN[license_applied]="License applied. Container recreated."
LANG_RU[license_applied]="Лицензия применена. Контейнер пересоздан."

LANG_EN[license_not_applied]="License saved but container not restarted. Apply on next restart."
LANG_RU[license_not_applied]="Лицензия сохранена, но контейнер не перезапущен. Применится при следующем запуске."

LANG_EN[compose_not_exist]="docker-compose.yml not found. Install WARP first."
LANG_RU[compose_not_exist]="docker-compose.yml не найден. Сначала установите WARP."

# ─── Translation function ────────────────────────────────────────────────────

t() {
    local key="$1"
    if [[ "$LANG_CHOICE" == "ru" ]]; then
        echo "${LANG_RU[$key]:-$key}"
    else
        echo "${LANG_EN[$key]:-$key}"
    fi
}

# ─── Parse arguments ─────────────────────────────────────────────────────────

for arg in "$@"; do
    case "$arg" in
        --lang=ru) LANG_CHOICE="ru" ;;
        --lang=en) LANG_CHOICE="en" ;;
    esac
done

# ─── UI functions ─────────────────────────────────────────────────────────────

show_success() {
    echo -e "  ${BOLD_GREEN}[OK]${NC} $1"
}

show_error() {
    echo -e "  ${BOLD_RED}[ERROR]${NC} $1"
}

show_warning() {
    echo -e "  ${BOLD_YELLOW}[WARN]${NC} $1"
}

show_info() {
    echo -e "  ${BOLD_BLUE}[INFO]${NC} $1"
}

draw_header() {
    clear
    echo ""
    echo -e "  ${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${BOLD_CYAN} ${NC} ${BOLD_WHITE}Docker${NC} ${BOLD_CYAN}WARP${NC} ${BOLD_WHITE}Native${NC}"
    echo -e "  ${DIM}  $(t subtitle)${NC}"
    echo -e "  ${BOLD_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

draw_section_header() {
    echo ""
    echo -e "  ${BOLD_CYAN}── $1 ──${NC}"
    echo ""
}

draw_separator() {
    echo -e "  ${DIM}────────────────────────────────────────${NC}"
}

draw_menu_options() {
    echo -e "  ${BOLD_GREEN}1)${NC} $(t menu_install)"
    echo -e "  ${BOLD_RED}2)${NC} $(t menu_uninstall)"
    echo -e "  ${BOLD_BLUE}3)${NC} $(t menu_update)"
    echo -e "  ${BOLD_BLUE}4)${NC} $(t menu_status)"
    echo -e "  ${BOLD_YELLOW}5)${NC} $(t menu_license)"
    echo -e "  ${DIM}0)${NC} $(t menu_exit)"
    echo ""
}

spinner() {
    local pid=$1
    local msg="${2:-}"
    local frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${BOLD_CYAN}%s${NC} %s" "${frames:i%${#frames}:1}" "$msg"
        i=$((i + 1))
        sleep 0.1
    done

    wait "$pid" 2>/dev/null
    local exit_code=$?
    printf "\r\033[K"
    return $exit_code
}

prompt_input() {
    local prompt_msg="$1"
    local var_name="$2"
    echo -ne "  ${BOLD_WHITE}${prompt_msg}: ${NC}"
    read -r "$var_name"
}

prompt_yes_no() {
    local prompt_msg="$1"
    local yes_char
    yes_char=$(t yes_no_y)

    echo -ne "  ${BOLD_WHITE}${prompt_msg} $(t yes_no_prompt): ${NC}"
    read -r answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
    [[ "$answer" == "$yes_char" || "$answer" == "y" ]]
}

prompt_menu_option() {
    echo -ne "  ${BOLD_WHITE}$(t your_choice): ${NC}" >&2
    read -r choice
    echo "$choice"
}

wait_enter() {
    echo ""
    echo -ne "  ${DIM}$(t press_enter)${NC}"
    read -r
}

# ─── System functions ─────────────────────────────────────────────────────────

check_root() {
    if [[ $EUID -ne 0 ]]; then
        show_error "$(t error_root)"
        exit 1
    fi
}

check_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian) ;;
            *)
                show_error "$(t error_distro)"
                show_info "$(t detected_distro): $PRETTY_NAME"
                exit 1
                ;;
        esac
        show_info "$(t detected_distro): $PRETTY_NAME"
    else
        show_error "$(t error_distro)"
        exit 1
    fi
}

install_dependencies() {
    show_info "$(t installing_deps)"
    (
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq > /dev/null 2>&1
        apt-get install -y -qq curl > /dev/null 2>&1
    ) &
    spinner $! "$(t installing_deps)"
    show_success "$(t deps_installed)"
}

install_docker() {
    if command -v docker &>/dev/null; then
        show_success "$(t docker_found): $(docker --version)"
        # Check docker compose plugin
        if ! docker compose version &>/dev/null; then
            show_error "$(t compose_not_found)"
            exit 1
        fi
        return 0
    fi

    show_warning "$(t docker_not_found)"

    if ! prompt_yes_no "$(t install_docker_prompt)"; then
        show_error "$(t docker_declined)"
        exit 1
    fi

    show_info "$(t installing_docker)"
    (
        curl -fsSL https://get.docker.com | sh > /dev/null 2>&1
        systemctl enable docker > /dev/null 2>&1
        systemctl start docker > /dev/null 2>&1
    ) &
    if spinner $! "$(t installing_docker)"; then
        show_success "$(t docker_installed)"
    else
        show_error "$(t docker_install_failed)"
        exit 1
    fi

    if ! docker compose version &>/dev/null; then
        show_error "$(t compose_not_found)"
        exit 1
    fi
}

# ─── Set WARP_LICENSE in docker-compose.yml ───────────────────────────────────

set_license_in_compose() {
    local license="$1"
    local file="$COMPOSE_FILE"

    if grep -q '#.*WARP_LICENSE' "$file"; then
        # Uncomment and set the license line
        sed -i 's|^.*#.*- WARP_LICENSE=.*|      - WARP_LICENSE='"$license"'|' "$file"
        # Uncomment the environment: line above it if commented
        sed -i 's|^.*#.*environment:.*|    environment:|' "$file"
    elif grep -q 'WARP_LICENSE=' "$file"; then
        # Replace existing license value
        sed -i 's|WARP_LICENSE=.*|WARP_LICENSE='"$license"'|' "$file"
    else
        # Add environment section before volumes
        sed -i '/^\s*volumes:/i\    environment:\n      - WARP_LICENSE='"$license"'' "$file"
    fi
}

# ─── Menu actions ─────────────────────────────────────────────────────────────

do_install() {
    draw_section_header "$(t menu_install)"

    # Check if already installed
    if [[ -f "$COMPOSE_FILE" ]]; then
        show_warning "$(t already_installed) $WARP_DIR"
        if ! prompt_yes_no "$(t reinstall_prompt)"; then
            show_info "$(t install_cancelled)"
            return
        fi
    fi

    # Install dependencies and Docker if needed
    install_dependencies
    install_docker

    # Create directory
    if [[ ! -d "$WARP_DIR" ]]; then
        mkdir -p "$WARP_DIR"
        show_success "$(t creating_dir) $WARP_DIR"
    fi

    # Ask for license
    local license=""
    prompt_input "$(t license_prompt)" license

    # Download docker-compose.yml
    show_info "$(t downloading_compose)"
    if ! curl -fsSL "$COMPOSE_URL" -o "$COMPOSE_FILE"; then
        show_error "$(t download_failed)"
        return
    fi

    # Apply license if provided
    if [[ -n "$license" ]]; then
        set_license_in_compose "$license"
        show_success "$(t license_set)"
    else
        show_info "$(t using_free)"
    fi

    # Pull latest image
    show_info "$(t pulling_image)"
    (
        docker compose -f "$COMPOSE_FILE" pull > /dev/null 2>&1
    ) &
    if spinner $! "$(t pulling_image)"; then
        show_success "$(t image_pulled)"
    else
        show_error "$(t pull_failed)"
        return
    fi

    # Start container
    show_info "$(t starting_container)"
    (
        docker compose -f "$COMPOSE_FILE" up -d > /dev/null 2>&1
    ) &
    if spinner $! "$(t starting_container)"; then
        show_success "$(t container_started)"
    else
        show_error "$(t start_failed)"
        return
    fi

    draw_separator
    show_success "$(t install_complete)"
    echo ""
    show_info "$(t verify_hint)"
    echo ""

    if prompt_yes_no "$(t show_logs_prompt)"; then
        echo ""
        docker compose -f "$COMPOSE_FILE" logs --tail 100
    fi
}

do_uninstall() {
    draw_section_header "$(t menu_uninstall)"

    if [[ ! -d "$WARP_DIR" ]]; then
        show_warning "$(t not_installed)"
        return
    fi

    # Stop container
    if [[ -f "$COMPOSE_FILE" ]]; then
        show_info "$(t stopping_container)"
        (
            docker compose -f "$COMPOSE_FILE" down > /dev/null 2>&1
        ) &
        spinner $! "$(t stopping_container)" || true
        show_success "$(t container_stopped)"
    fi

    # Ask about removing config
    if prompt_yes_no "$(t remove_config_prompt) ($WARP_DIR)?"; then
        rm -rf "$WARP_DIR"
        show_success "$(t config_removed): $WARP_DIR"
    else
        show_info "$(t config_kept) $WARP_DIR"
    fi

    draw_separator
    show_success "$(t uninstall_complete)"
}

do_update() {
    draw_section_header "$(t menu_update)"

    if [[ ! -f "$COMPOSE_FILE" ]]; then
        show_warning "$(t not_installed)"
        return
    fi

    # Pull latest image
    show_info "$(t pulling_image)"
    (
        docker compose -f "$COMPOSE_FILE" pull > /dev/null 2>&1
    ) &
    if spinner $! "$(t pulling_image)"; then
        show_success "$(t image_pulled)"
    else
        show_error "$(t pull_failed)"
        return
    fi

    # Recreate container
    show_info "$(t recreating_container)"
    (
        docker compose -f "$COMPOSE_FILE" down > /dev/null 2>&1
        docker compose -f "$COMPOSE_FILE" up -d > /dev/null 2>&1
    ) &
    if spinner $! "$(t recreating_container)"; then
        show_success "$(t update_complete)"
    else
        show_error "$(t start_failed)"
    fi
}

do_status() {
    draw_section_header "$(t status_header)"

    if [[ ! -f "$COMPOSE_FILE" ]]; then
        show_warning "$(t not_installed)"
        return
    fi

    # Container status
    echo -e "  ${BOLD_WHITE}$(t container_status):${NC}"
    echo ""
    docker compose -f "$COMPOSE_FILE" ps 2>/dev/null || true
    echo ""

    draw_separator

    # Recent logs
    echo ""
    echo -e "  ${BOLD_WHITE}$(t recent_logs):${NC}"
    echo ""
    docker compose -f "$COMPOSE_FILE" logs --tail 100 2>/dev/null || true
    echo ""

    draw_separator

    # Connection check
    echo ""
    echo -e "  ${BOLD_WHITE}$(t connection_check):${NC}"
    echo ""
    if curl -s --interface warp --max-time 5 https://ipinfo.io 2>/dev/null; then
        echo ""
    else
        show_warning "$(t warp_not_running)"
    fi
}

do_license() {
    draw_section_header "$(t menu_license)"

    if [[ ! -f "$COMPOSE_FILE" ]]; then
        show_warning "$(t compose_not_exist)"
        return
    fi

    # Show current compose
    echo -e "  ${BOLD_WHITE}$(t current_compose):${NC}"
    echo ""
    sed 's/^/    /' "$COMPOSE_FILE"
    echo ""

    draw_separator
    echo ""

    # Prompt for license
    local license=""
    prompt_input "$(t enter_license)" license

    if [[ -z "$license" ]]; then
        show_error "$(t license_empty)"
        return
    fi

    set_license_in_compose "$license"
    show_success "$(t license_updated)"

    echo ""
    if prompt_yes_no "$(t license_restart_prompt)"; then
        show_info "$(t recreating_container)"
        # Remove existing warp config to force re-registration with new license
        rm -f "$WARP_DIR/warp.conf" "$WARP_DIR/wgcf-profile.conf" "$WARP_DIR/wgcf-account.toml"
        (
            docker compose -f "$COMPOSE_FILE" down > /dev/null 2>&1
            docker compose -f "$COMPOSE_FILE" up -d > /dev/null 2>&1
        ) &
        if spinner $! "$(t recreating_container)"; then
            show_success "$(t license_applied)"
        else
            show_error "$(t start_failed)"
        fi
    else
        show_info "$(t license_not_applied)"
    fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    check_root
    check_distro

    while true; do
        draw_header
        echo -e "  ${BOLD_WHITE}$(t select_action):${NC}"
        echo ""
        draw_menu_options

        choice=$(prompt_menu_option)

        case "$choice" in
            1) do_install ;;
            2) do_uninstall ;;
            3) do_update ;;
            4) do_status ;;
            5) do_license ;;
            0) echo ""; exit 0 ;;
            *) show_error "$(t invalid_choice)" ;;
        esac

        wait_enter
    done
}

main
