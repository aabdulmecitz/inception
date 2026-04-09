COMPOSE		= docker-compose -f srcs/docker-compose.yml
DATA_DIR	= /home/aozkaya/data
ENV_FILE	= srcs/.env
SECRETS_DIR	= secrets

all: up

init: env secrets

secrets:
	@mkdir -p $(SECRETS_DIR)
	@touch $(SECRETS_DIR)/db_password.txt
	@touch $(SECRETS_DIR)/db_root_password.txt
	@touch $(SECRETS_DIR)/credentials.txt
	@chmod 600 $(SECRETS_DIR)/db_password.txt $(SECRETS_DIR)/db_root_password.txt $(SECRETS_DIR)/credentials.txt
	@echo "Secrets templates ready in $(SECRETS_DIR)/"

env:
	@mkdir -p $(dir $(ENV_FILE))
	@test -f $(ENV_FILE) || printf '%s\n' \
		'DOMAIN_NAME=aozkaya.42.fr' \
		'MYSQL_DATABASE=wordpress' \
		'MYSQL_USER=aozkaya_wp' \
		'WP_TITLE=aozkaya' \
		'WP_ADMIN_USER=aozkaya_owner' \
		'WP_ADMIN_EMAIL=owner@aozkaya.42.fr' \
		'WP_USER=aozkaya_writer' \
		'WP_USER_EMAIL=writer@aozkaya.42.fr' \
		> $(ENV_FILE)

up:
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean: down
	$(COMPOSE) down --rmi all --volumes --remove-orphans

fclean: clean
	sudo rm -rf $(DATA_DIR)

re: fclean up

.PHONY: all init env secrets up down clean fclean re
