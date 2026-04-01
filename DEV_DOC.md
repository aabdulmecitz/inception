# DEV_DOC

## Environment setup from scratch
### Prerequisites
- Linux VM
- Docker engine
- Docker Compose plugin

### Required configuration files
- `srcs/.env` (auto-created by `make run` if missing)
- Optional local secrets files if you extend with Docker secrets

### Host data directories
The project persists data under:
- `/home/<login>/data/mariadb`
- `/home/<login>/data/wordpress`

These are created automatically by the Makefile.

## Build and launch with Makefile + Compose
- Build images: `make build`
- Build + run: `make run` (or `make`)
- Full setup: `make setall`
- Stop: `make down`
- Remove containers and local images: `make clean`
- Full cleanup including volumes: `make fclean`
- Rebuild all: `make re`

Compose file:
- `srcs/docker-compose.yml`

## Useful container and volume commands
- Service status:
  - `docker compose -p inception -f srcs/docker-compose.yml ps`
- Follow logs:
  - `docker compose -p inception -f srcs/docker-compose.yml logs -f`
- Enter container shell:
  - `docker compose -p inception -f srcs/docker-compose.yml exec nginx bash`
  - `docker compose -p inception -f srcs/docker-compose.yml exec wordpress bash`
  - `docker compose -p inception -f srcs/docker-compose.yml exec mariadb bash`
- List volumes:
  - `docker volume ls`
- Inspect a volume:
  - `docker volume inspect <volume_name>`

## Evaluation-oriented checks
- No forbidden network mode: ensure no `network: host`, no `links`, no `--link`
- No hacky loop process: no `tail -f`, `sleep infinity`, `while true`
- NGINX only on port `443`, TLS only `1.2/1.3`
- Named volumes point to `/home/<login>/data/*`
- WordPress admin username must not contain `admin`

## Data location and persistence model
- MariaDB data persists in named volume `mariadb_data`.
- WordPress data persists in named volume `wordpress_data`.
- Both named volumes are configured to store host-side data under `/home/<login>/data`.
- Data remains after container recreation unless removed with full cleanup.
