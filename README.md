*This project has been created as part of the 42 curriculum by aozkaya.*

# Inception

## Description
This project builds a secure WordPress stack with Docker Compose in a VM.

Services:
- `nginx`: only public entrypoint on port `443` with TLS (`v1.2/v1.3`)
- `wordpress`: PHP-FPM + WordPress
- `mariadb`: database backend

Infrastructure:
- one dedicated Docker bridge network
- two named volumes stored on host under `/home/<login>/data`

## System diagram
`Browser -> 443/TLS -> NGINX -> wordpress:9000 -> mariadb:3306`

## Project Description and Design Choices
### Why Docker in this project
Docker gives process isolation, reproducibility, and clean service boundaries with Compose orchestration.

### Included sources
- `Makefile`: build/run lifecycle
- `srcs/docker-compose.yml`: services, network, volumes
- `srcs/requirements/nginx`: NGINX Dockerfile + TLS config
- `srcs/requirements/wordpress`: WordPress/PHP-FPM Dockerfile + setup script
- `srcs/requirements/mariadb`: MariaDB Dockerfile + init script

### Required comparisons
#### Virtual Machines vs Docker
- VM: full guest OS, heavier and slower startup.
- Docker: shared host kernel, lighter and faster.

#### Secrets vs Environment Variables
- `.env`: convenient for configuration and project variables.
- Docker secrets: better for sensitive credentials in production.

#### Docker Network vs Host Network
- Bridge network: isolated traffic + internal DNS by service name.
- Host network: no isolation, forbidden for this project.

#### Docker Volumes vs Bind Mounts
- Named volumes: managed persistence and portability.
- Bind mounts: direct host coupling; more fragile.

## Instructions
### Prerequisites
- Linux VM
- Docker + Docker Compose plugin
- `/etc/hosts` entry for your domain (example):
  - `127.0.0.1 <login>.42.fr`

### Configuration
The project requires `srcs/.env` to run.
- If missing, `make run` auto-generates a default `srcs/.env` template.
- `make setall` also creates it automatically during one-shot setup.
- After creation, edit `srcs/.env` with your real credentials and login.

### Build and run
- `make run` (recommended)
- `make` (alias of `make run`)
- one-shot full setup + run: `make setall`

### Stop
- `make down`

### Clean
- `make clean` (containers + local images)
- `make fclean` (full cleanup including volumes)

### Quick defense script (30 seconds)
1. “There are 3 containers: NGINX, WordPress(PHP-FPM), MariaDB.”
2. “Only NGINX is exposed, only on `443` with TLS 1.2/1.3.”
3. “Containers communicate on a dedicated bridge network.”
4. “Data persists in named volumes mapped to `/home/<login>/data`.”
5. “`make run` starts everything; `make setall` performs full first-time setup.”

## Validation checklist (mandatory)
- Only NGINX exposes port 443
- TLS is restricted to v1.2/v1.3
- No prebuilt service images are pulled
- Each service has its own Dockerfile/container
- WordPress and MariaDB persist through named volumes
- Both volumes store data under `/home/<login>/data`
- Dedicated Docker network is defined in compose
- Containers restart on failure
- WordPress has 2 users (admin + regular user)

## Resources
- Docker docs: https://docs.docker.com/
- Compose docs: https://docs.docker.com/compose/
- NGINX docs: https://nginx.org/en/docs/
- MariaDB docs: https://mariadb.org/documentation/
- WordPress CLI docs: https://developer.wordpress.org/cli/commands/

### AI usage disclosure
AI was used as a learning support system for:
- understanding mandatory subject expectations and evaluation criteria
- comparing implementation options before coding
- reviewing scripts for robustness ideas (runtime checks and env validation)
- improving documentation clarity and structure

Final technical decisions, implementation, testing, and validation were done manually.
