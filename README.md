*This project has been created as part of the 42 curriculum by aozkaya.*

# Description
This project sets up a small Docker-based infrastructure for a WordPress website. It uses three dedicated services: NGINX as the TLS entrypoint, WordPress with PHP-FPM for the application layer, and MariaDB for persistence. The goal is to run the stack in a virtual machine with Docker Compose, using custom Dockerfiles and persistent storage for the database and website files.

## Project Description and Design Choices
The stack is built from the penultimate stable Debian image for each service. Each service has its own Dockerfile and runs in its own container. NGINX is the only public entrypoint and exposes port 443 with TLSv1.2 or TLSv1.3 only. WordPress and MariaDB are internal services that communicate over a private Docker network.

The project includes these sources:
- `Makefile` for the build and lifecycle commands.
- `srcs/docker-compose.yml` for service orchestration, networking, volumes, and secrets.
- `srcs/requirements/nginx` for the NGINX image and TLS configuration.
- `srcs/requirements/wordpress` for the WordPress + PHP-FPM image and bootstrap script.
- `srcs/requirements/mariadb` for the MariaDB image and database initialization script.

Comparison of the main design choices:
- Virtual Machines vs Docker: a VM runs a full guest OS, while Docker shares the host kernel and is lighter and faster to start.
- Secrets vs Environment Variables: environment variables are convenient for non-sensitive configuration, while secrets are better for credentials and passwords.
- Docker Network vs Host Network: a bridge network isolates services and lets them resolve each other by name, while host networking removes isolation and is forbidden here.
- Docker Volumes vs Bind Mounts: volumes are the preferred persistent storage mechanism for this project; bind mounts are not allowed for the WordPress data and database storage.

## Instructions
1. Run `make init` to generate `srcs/.env` and create local secret templates under `secrets/`.
2. Fill `secrets/db_password.txt`, `secrets/db_root_password.txt`, and `secrets/credentials.txt` with real values.
3. Make sure `DOMAIN_NAME=aozkaya.42.fr` and `/etc/hosts` contains `127.0.0.1 aozkaya.42.fr`.
4. Build and start the stack with `make`.
5. Stop it with `make down`, clean containers/images/volumes with `make clean`, and remove persistent host data with `make fclean`.

## Resources
- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- NGINX documentation: https://nginx.org/en/docs/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- WordPress CLI documentation: https://developer.wordpress.org/cli/commands/
- AI usage: AI was used as a drafting aid to help rewrite and organize the documentation and refine the wording. Final project decisions, implementation details, and validation were reviewed manually.
