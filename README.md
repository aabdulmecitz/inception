*This project has been created as part of the 42 curriculum by aozkaya.*

# Inception

## Description
This project deploys a small multi-service infrastructure with Docker Compose, following the mandatory Inception rules.

The stack contains exactly three services:
- `nginx` (TLS termination, only port 443 exposed)
- `wordpress` (WordPress + PHP-FPM, no nginx)
- `mariadb` (database only)

It also uses:
- one dedicated Docker network
- two named volumes for persistence:
  - WordPress files
  - MariaDB data

## System diagram
Expected traffic/data flow is:

`WWW -> 443 -> NGINX -> 9000 -> WordPress/PHP-FPM -> 3306 -> MariaDB`

Persistent storage:
- MariaDB container -> `mariadb_data`
- WordPress container -> `wordpress_data`

## Project Description and Design Choices
### Why Docker in this project
Docker provides isolated services, reproducible builds, and simple orchestration with Compose. It allows each service to stay independent and connected only through an explicit network.

### Included sources
- [Makefile](Makefile): project lifecycle commands
- [srcs/docker-compose.yml](srcs/docker-compose.yml): service orchestration, network, volumes
- [srcs/.env.example](srcs/.env.example): environment variable template
- [srcs/requirements/mariadb](srcs/requirements/mariadb): MariaDB image and init script
- [srcs/requirements/wordpress](srcs/requirements/wordpress): WordPress + PHP-FPM image and install script
- [srcs/requirements/nginx](srcs/requirements/nginx): NGINX image, TLS, runtime config template

### Required comparisons
#### Virtual Machines vs Docker
- VM: virtualizes full OS, heavier resource usage, slower boot.
- Docker: process-level isolation on host kernel, lighter, faster startup.

#### Secrets vs Environment Variables
- Environment variables are convenient for non-sensitive configuration.
- Secrets are safer for credentials because they are not stored directly in image layers or plain text env files.

#### Docker Network vs Host Network
- Docker bridge network isolates container traffic and enables service-name DNS.
- Host network removes that isolation and is forbidden by project rules.

#### Docker Volumes vs Bind Mounts
- Docker named volumes are managed by Docker and easier to migrate and control.
- Bind mounts directly couple services to host paths and are less portable.

## Instructions
### Prerequisites
- Linux VM
- Docker + Docker Compose plugin
- `/etc/hosts` entry for your domain:
  - `127.0.0.1 aozkaya.42.fr` (or your VM IP)

### Configuration
1. Copy [srcs/.env.example](srcs/.env.example) to `srcs/.env`.
2. Fill all values in `srcs/.env`.
3. Keep admin username compliant (must not contain `admin`).

### Build and run
- `make`
- or `make up`
- or one-shot setup: `bash setup.sh`

### Stop
- `make down`

### Clean
- `make clean` (containers + local images)
- `make fclean` (full cleanup including volumes)

## Validation checklist (mandatory)
- Only NGINX exposes port 443
- TLS is restricted to v1.2/v1.3
- No prebuilt service images are pulled
- Each service has its own Dockerfile/container
- WordPress and MariaDB persist through named volumes
- Both volumes store data under `/home/aozkaya/data`
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
AI assistance was used for:
- requirement cross-checking against the mandatory subject
- script hardening suggestions (runtime checks and env validation)
- documentation drafting and structure alignment

All architecture decisions, final implementation, and verification were reviewed and adjusted manually.
