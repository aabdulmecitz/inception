# USER_DOC

## Provided services
This stack provides three services:
- `nginx`: HTTPS reverse proxy and entrypoint
- `wordpress`: CMS application running on PHP-FPM
- `mariadb`: database backend for WordPress

## Start and stop
- Start: `make` or `make up`
- Stop: `make down`
- Rebuild from scratch: `make re`
- Full cleanup: `make fclean`

## Access the website and admin panel
1. Add your domain in `/etc/hosts` (example):
   - `127.0.0.1 aozkaya.42.fr`
2. Open:
   - Website: `https://aozkaya.42.fr`
   - Admin panel: `https://aozkaya.42.fr/wp-admin`

## Credentials management
- Credentials are stored in `srcs/.env` (local file).
- Do not commit real credentials.
- Use `srcs/.env.example` as template.

## Verify services are running correctly
- Container status: `docker compose -p inception -f srcs/docker-compose.yml ps`
- Logs: `docker compose -p inception -f srcs/docker-compose.yml logs -f`
- Check HTTPS: open `https://aozkaya.42.fr` and confirm certificate/TLS works.
