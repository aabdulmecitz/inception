PROJ		= inception
COMPOSE		= docker compose -p $(PROJ) -f srcs/docker-compose.yml
DATA_DIR		= /home/$(USER)/data
ENV_FILE		= srcs/.env

.PHONY: all build up run down clean fclean re create_all setup_dirs ensure_env setall

all: run

ensure_env:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "[INFO] Missing $(ENV_FILE), creating default template"; \
		printf '%s\n' \
		'OS_VERSION=bookworm' \
		'' \
		'# Project General Settings' \
		'DOMAIN_NAME=$(USER).42.fr' \
		'DATA_ROOT=/home/$(USER)/data' \
		'' \
		'# NGINX TLS certificate subject' \
		'SSL_COUNTRY=TR' \
		'SSL_STATE=Istanbul' \
		'SSL_LOCALITY=Istanbul' \
		'SSL_ORG=42Istanbul' \
		'SSL_OU=Student' \
		'' \
		'# Database Information' \
		'SQL_DATABASE=wordpress' \
		'SQL_USER=wp_user' \
		'SQL_PASSWORD=change_me_sql_user_password' \
		'SQL_HOST=mariadb' \
		'SQL_ROOT_PASSWORD=change_me_sql_root_password' \
		'' \
		'# WordPress Information' \
		'SITE_TITLE=Inception' \
		'WP_ADMIN_USER=siteowner' \
		'WP_ADMIN_PASSWORD=change_me_wp_admin_password' \
		'WP_ADMIN_EMAIL=admin@student.42.fr' \
		'' \
		'WP_USER=authoruser' \
		'WP_PASSWORD=change_me_wp_user_password' \
		'WP_EMAIL=user@student.42.fr' \
		> $(ENV_FILE); \
	fi

setup_dirs:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	chmod 755 $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress 2>/dev/null || true

build: setup_dirs ensure_env
	$(COMPOSE) build

up: build
	$(COMPOSE) up -d

run: setall up

setall:
	bash setup.sh --prepare

down:
	$(COMPOSE) down

clean: down
	$(COMPOSE) down --rmi local

fclean:
	$(COMPOSE) down --rmi all -v

re: fclean
	$(MAKE) build
	$(MAKE) up

create_all:
	$(MAKE) setall

