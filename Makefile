NAME		= inception
COMPOSE		= docker compose -p $(NAME) -f docker-compose.yml

.PHONY: all build up down clean fclean re

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

