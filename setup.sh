#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_CMD=(docker compose -p inception -f "$PROJECT_ROOT/srcs/docker-compose.yml")
ENV_FILE="$PROJECT_ROOT/srcs/.env"
ENV_EXAMPLE="$PROJECT_ROOT/srcs/.env.example"

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
err() { echo "[ERROR] $*"; }

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        err "Missing command: $1"
        exit 1
    }
}

write_env_var() {
    local key="$1"
    local value="$2"

    if grep -qE "^${key}=" "$ENV_FILE"; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
    else
        printf '%s=%s\n' "$key" "$value" >> "$ENV_FILE"
    fi
}

ensure_hosts_entry() {
    local domain="$1"
    local target_ip="$2"

    if grep -qE "(^|[[:space:]])${domain}([[:space:]]|$)" /etc/hosts; then
        info "Hosts entry already exists for ${domain}"
        return
    fi

    info "Adding ${domain} to /etc/hosts"
    if [[ "$(id -u)" -eq 0 ]]; then
        printf '%s %s\n' "$target_ip" "$domain" >> /etc/hosts
    else
        printf '%s %s\n' "$target_ip" "$domain" | sudo tee -a /etc/hosts >/dev/null
    fi
}

main() {
    info "Starting one-shot Inception setup"

    require_cmd docker
    if ! docker compose version >/dev/null 2>&1; then
        err "Docker Compose plugin is required"
        exit 1
    fi

    if ! docker info >/dev/null 2>&1; then
        err "Docker daemon is not accessible. Start Docker or fix socket permissions."
        echo "Try: sudo systemctl start docker"
        echo "Then: sudo usermod -aG docker \$USER && re-login"
        exit 1
    fi

    if [[ ! -f "$ENV_FILE" ]]; then
        if [[ -f "$ENV_EXAMPLE" ]]; then
            info "Creating srcs/.env from srcs/.env.example"
            cp "$ENV_EXAMPLE" "$ENV_FILE"
        else
            err "Missing srcs/.env and srcs/.env.example"
            exit 1
        fi
    fi

    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a

    : "${DOMAIN_NAME:?DOMAIN_NAME must be set in srcs/.env}"

    local login_user
    login_user="${SUDO_USER:-${USER}}"
    local default_data_root="/home/${login_user}/data"

    if [[ -z "${DATA_ROOT:-}" ]]; then
        DATA_ROOT="$default_data_root"
        write_env_var "DATA_ROOT" "$DATA_ROOT"
        info "Set DATA_ROOT=${DATA_ROOT} in srcs/.env"
    fi

    info "Ensuring data directories: ${DATA_ROOT}/mariadb and ${DATA_ROOT}/wordpress"
    if [[ "$(id -u)" -eq 0 ]]; then
        mkdir -p "${DATA_ROOT}/mariadb" "${DATA_ROOT}/wordpress"
    else
        mkdir -p "${DATA_ROOT}/mariadb" "${DATA_ROOT}/wordpress" || \
        sudo mkdir -p "${DATA_ROOT}/mariadb" "${DATA_ROOT}/wordpress"
    fi

    ensure_hosts_entry "$DOMAIN_NAME" "127.0.0.1"

    info "Building images"
    "${COMPOSE_CMD[@]}" build

    info "Starting containers"
    "${COMPOSE_CMD[@]}" up -d

    info "Current service status"
    "${COMPOSE_CMD[@]}" ps

    echo
    echo "Setup completed."
    echo "Open: https://${DOMAIN_NAME}"
    echo "Admin: https://${DOMAIN_NAME}/wp-admin"
}

main "$@"
