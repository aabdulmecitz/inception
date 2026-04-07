# Developer Notes

## Overview
This repository contains three Dockerized services on a private bridge network:
- NGINX as the HTTPS entrypoint.
- WordPress with PHP-FPM for the application layer.
- MariaDB for persistence.

## Identity used in this workspace
- Login: `aozkaya`
- Domain: `aozkaya.42.fr`
- Data root: `/home/aozkaya/data`

## Setup from Scratch
Prerequisites:
- A Linux virtual machine with Docker and Docker Compose available.
- A local hosts entry for `aozkaya.42.fr`.

Required files:
- `srcs/.env` for environment variables. Generate it with `make env` if you want the default template.
- `secrets/db_password.txt`, `secrets/db_root_password.txt`, and `secrets/credentials.txt` for credentials.

## Build flow
1. The Makefile creates the host directories for persistent data.
2. Compose starts MariaDB first, then WordPress, then NGINX.
3. MariaDB initializes only once by using a sentinel file in the data volume.
4. WordPress downloads core files, creates its config, then installs the site if needed.
5. NGINX serves TLS with a self-signed certificate generated at image build time.

## Build and launch
- Generate the default environment file: `make env`
- Build and start: `make`
- Stop containers: `make down`
- Remove images and volumes: `make clean`
- Full reset including host data: `make fclean`
- Rebuild from scratch: `make re`

## Container and Volume Management
- Check status: `docker compose -f srcs/docker-compose.yml ps`
- View logs: `docker compose -f srcs/docker-compose.yml logs`
- Inspect volumes: `docker volume ls` and `docker volume inspect mariadb_vol`
- The persistent data lives under `/home/aozkaya/data/mariadb` and `/home/aozkaya/data/wordpress`.

## Important files
- `Makefile` for lifecycle commands.
- `srcs/docker-compose.yml` for service wiring.
- `srcs/requirements/mariadb/tools/init-db.sh` for database bootstrap.
- `srcs/requirements/wordpress/tools/setup-wp.sh` for WordPress bootstrap.
- `srcs/requirements/nginx/conf/nginx.conf` for the reverse proxy config.

## Operational notes
- Keep secrets out of the repository.
- The stack uses named volumes whose data is stored under `/home/aozkaya/data`.
- Restart-safe initialization matters more than one-shot setup because volumes survive rebuilds.
