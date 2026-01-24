# inception

## Project Overview

This project sets up a small infrastructure composed of three Docker containers:
- **nginx**: reverse proxy and HTTPS termination
- **wordpress**: PHP-FPM + WordPress application
- **mariadb**: database server for WordPress

All containers are built from a `debian` base image and orchestrated using `docker-compose.yml`.

## Roadmap

### 1. Global Setup

- **Define environment variables**
  - Create a `.env` file at the project root.
  - Add variables for:
    - Domain name (e.g. `DOMAIN_NAME`)
    - MariaDB root password, user, password, and database name
    - WordPress admin/user credentials

- **Check basic structure**
  - Keep the three services: `nginx`, `wordpress`, `mariadb` under `srcs/`.
  - Ensure `docker-compose.yml` points to the correct build contexts:
    - `./srcs/nginx`
    - `./srcs/wordpress`
    - `./srcs/mariadb`

### 2. MariaDB Service (`srcs/mariadb`)

- **Dockerfile**
  - Start from `debian:${OS_VERSION}`.
  - Install MariaDB server and client.
  - Create a non-root user to run the service.
  - Copy a `tools/setup.sh` script and make it the container entrypoint or command.

- **Setup script**
  - Read credentials from environment variables.
  - Initialize the database, create the WordPress database and user.
  - Ensure the data directory is owned by the non-root user.

- **Compose configuration**
  - In `docker-compose.yml`, add a named volume for MariaDB data.
  - Attach the service to `inception-network`.

### 3. WordPress Service (`srcs/wordpress`)

- **Dockerfile**
  - Start from `debian:${OS_VERSION}`.
  - Install PHP-FPM and required PHP extensions.
  - Download and install WordPress into a web root directory.
  - Create and configure `wp-config.php` using environment variables.

- **Runtime configuration**
  - Configure PHP-FPM to listen on a socket or port that nginx can reach.
  - Make sure file permissions allow the non-root user to run PHP-FPM and write where needed.

- **Compose configuration**
  - Add a volume for WordPress data (uploads, etc.) if required by the subject.
  - Use `env_file: .env` to inject environment variables (already present).
  - Link `wordpress` to `mariadb` via the common network.

### 4. Nginx Service (`srcs/nginx`)

- **Dockerfile**
  - Start from `debian:${OS_VERSION}`.
  - Install nginx and openssl.
  - Create a non-root user for nginx.
  - Copy nginx configuration and SSL certificates into the image.

- **SSL & configuration**
  - Write a script to generate a self-signed certificate (or follow project requirements).
  - Configure nginx:
    - Listen on port 443 with SSL.
    - Use the generated certificate and key.
    - Proxy PHP requests to the WordPress/PHP-FPM service.
    - Set the server name to your domain from `.env`.

- **Compose configuration**
  - Expose port `443:443` (already present).
  - Attach the service to `inception-network`.

### 5. `docker-compose.yml` Refinement

- **Add volumes**
  - Define named volumes for:
    - MariaDB data
    - WordPress data (if required)

- **Service dependencies**
  - Use `depends_on` so that `wordpress` waits for `mariadb`.
  - Optionally, ensure `nginx` depends on `wordpress`.

- **Restart policies**
  - Add `restart: always` (or as required) for each service.

### 6. Makefile (`Makefile`)

- **Implement standard targets**
  - `make build`: build all Docker images.
  - `make up`: start containers with `docker compose up -d`.
  - `make down`: stop containers with `docker compose down`.
  - `make clean`: remove containers and images created for the project.
  - `make fclean`: full cleanup including named volumes.
  - `make re`: run `fclean` then `build` and `up`.

### 7. Testing Checklist

- **MariaDB**
  - Check that the database and user defined in `.env` are created.
  - Verify that data persists across container restarts.

- **WordPress**
  - Access the WordPress setup page.
  - Complete installation and log in to the admin dashboard.

- **Nginx & SSL**
  - Open `https://<your-domain>` in a browser.
  - Confirm that nginx serves WordPress over HTTPS.
  - Check that the proxy to PHP-FPM is working (no 502/504 errors).

  **NOTES**
  standardly when we open a volume the system includes the data to where named **/var/lib/docker/volumes/xxxxx** so we dont need this. the subject says Both named volumes must store their data inside /home/login/data on the host machine." "You must use Docker named volumes for these two persistent storages. Bind mounts are not allowed for these volumes. Throughout, We redefined the saving data places as **/home/aozkaya/data/wordpress and /home/aozkaya/data/mariadb**.

  services:
    mariadb:
      image: mariadb
        ... diğer ayarlar ...
      deploy:
        resources:
          limits:
            cpus: '0.50'    # İşlemcinin yarısını (%50) kullanabilir.
            memory: 512M    # En fazla 512 Megabyte RAM kullanabilir.
          reservations:
            cpus: '0.25'    # En az %25 işlemci gücünü ona garanti et.
            memory: 128M    # En az 128 MB RAM'i ona ayır.

  **docker exec -it nginx bash** you can enter inside of the docker container. however the thing is just an illusion. you have not exactly any permission, ram or cpu. everything is a illusion. so that makes senes why the project name is inception. normally the virtual machines provides a isolated machines but docker provides isolated processes. actually you are not build any isolated machine, it just a program that is isolated with a jail cell.

  RUN working for building time. but CMD works just a time.

  
Once all these steps are working, your mandatory part of the Inception project should be complete.
