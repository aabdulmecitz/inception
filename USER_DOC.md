# USER_DOC

## Provided services
- `nginx`: HTTPS entrypoint (`443` only)
- `wordpress`: website app (PHP-FPM)
- `mariadb`: website database

## Start and stop
- First-time prerequisite setup: `make setall`
- Normal start: `make run` (or `make`)
- Stop: `make down`
- Rebuild from scratch: `make re`
- Full cleanup: `make fclean`

## Access the website and admin panel
1. Add your domain in `/etc/hosts` (example):
   - `127.0.0.1 <login>.42.fr`
2. Open:
   - Website: `https://<login>.42.fr`
   - Admin panel: `https://<login>.42.fr/wp-admin`

## Credentials management
- Credentials are stored in `srcs/.env` (local file).
- If `srcs/.env` is missing, `make run` auto-creates it with default values.
- Do not commit real credentials.
- Edit `srcs/.env` after creation and set your real credentials.

## Verify services are running correctly
- Container status: `docker compose -p inception -f srcs/docker-compose.yml ps`
- Logs: `docker compose -p inception -f srcs/docker-compose.yml logs -f`
- Check HTTPS: open `https://<login>.42.fr` and confirm certificate/TLS works.

## Quick demo for evaluator
1. Run `make run`.
2. Show `docker compose -p inception -f srcs/docker-compose.yml ps`.
3. Open `https://<login>.42.fr` (works), try `http://<login>.42.fr` (must fail).
4. Log in to `/wp-admin` with admin user (username does not contain `admin`).
