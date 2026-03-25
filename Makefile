PROJ		= inception
COMPOSE		= docker compose -p $(PROJ) -f srcs/docker-compose.yml
DATA_DIR		= /home/aozkaya/data

.PHONY: all build up down clean fclean re create_all setup_dirs

all: up

setup_dirs:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	chmod 755 $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress 2>/dev/null || true

build: setup_dirs
	$(COMPOSE) build

up: build
	$(COMPOSE) up -d

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
	bash setup.sh

