PROJ		= inception
COMPOSE		= docker compose -p $(PROJ) -f srcs/docker-compose.yml

.PHONY: all build up down clean fclean re create_all

all: build

build:
	$(COMPOSE) build

up:
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
	bash srcs/requirements/tools/setup.sh

