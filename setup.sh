#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_CMD=(docker compose -p inception -f "$PROJECT_ROOT/srcs/docker-compose.yml")
ENV_FILE="$PROJECT_ROOT/srcs/.env"

info() { echo "[INFO] $*"; }
warn() { echo "[WARN] $*"; }
err() { echo "[ERROR] $*"; }

usage() {
        cat <<EOF
Usage: $0 [--prepare|--no-start]

Options:
    --prepare, --no-start   Only do prerequisite setup (.env, data dirs, /etc/hosts).
    -h, --help              Show this help message.
EOF
}

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

create_default_env() {
    local login_user="$1"

    cat > "$ENV_FILE" <<EOF
OS_VERSION=bookworm

# Project General Settings
DOMAIN_NAME=${login_user}.42.fr
DATA_ROOT=/home/${login_user}/data

# NGINX TLS certificate subject
SSL_COUNTRY=TR
SSL_STATE=Istanbul
SSL_LOCALITY=Istanbul
SSL_ORG=42Istanbul
SSL_OU=Student

# Database Information
SQL_DATABASE=wordpress
SQL_USER=wp_user
SQL_PASSWORD=change_me_sql_user_password
SQL_HOST=mariadb
SQL_ROOT_PASSWORD=change_me_sql_root_password

# WordPress Information
SITE_TITLE=Inception
WP_ADMIN_USER=siteowner
WP_ADMIN_PASSWORD=change_me_wp_admin_password
WP_ADMIN_EMAIL=admin@student.42.fr

WP_USER=authoruser
WP_PASSWORD=change_me_wp_user_password
WP_EMAIL=user@student.42.fr
EOF
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
    local prepare_only=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --prepare|--no-start)
                prepare_only=true
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                err "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

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

    local login_user
    login_user="${SUDO_USER:-${USER}}"

    if [[ ! -f "$ENV_FILE" ]]; then
        info "Creating default srcs/.env"
        create_default_env "$login_user"
    fi

    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a

    : "${DOMAIN_NAME:?DOMAIN_NAME must be set in srcs/.env}"

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

    if [[ "$prepare_only" == true ]]; then
        echo
        echo "Setup completed (prepare-only)."
        echo "Run 'make' to build and start containers."
        return
    fi

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
