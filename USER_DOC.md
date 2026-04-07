# aozkaya User Guide

## Access
- Site: `https://aozkaya.42.fr`
- Admin panel: `https://aozkaya.42.fr/wp-admin`

## Services
- `nginx` is the public HTTPS entrypoint.
- `wordpress` runs PHP-FPM and serves the application layer.
- `mariadb` stores the WordPress database.

## Start and stop
- Start: `make`
- Stop: `make down`
- Clean images and volumes: `make clean`
- Full reset including host data: `make fclean`
- Rebuild from scratch: `make re`

## First run checklist
1. Add `127.0.0.1 aozkaya.42.fr` to `/etc/hosts`.
2. Create the secret files required by `srcs/docker-compose.yml`.
3. Generate `srcs/.env` with `make env` if you want the default template.
4. Launch the project with `make`.

## Credentials
- Environment values are stored in `srcs/.env`.
- Secret values are stored in `secrets/db_password.txt`, `secrets/db_root_password.txt`, and `secrets/credentials.txt`.
- Do not commit those files.

## What the user should see
- Visiting the site opens WordPress over HTTPS.
- The certificate is generated for `aozkaya.42.fr`.
- WordPress admin and author accounts are created during the first initialization.

## Validation hints
- Only port `443` should be exposed publicly.
- The site should resolve through the local hosts entry.
- Database and site content should persist across restarts because they live under `/home/aozkaya/data`.
- To check the stack, use `docker compose -f srcs/docker-compose.yml ps` and `docker compose -f srcs/docker-compose.yml logs`.
