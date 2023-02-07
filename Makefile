# Executables (local)
DOCKER_COMP = docker compose

# Docker containers
PHP_CONT = $(DOCKER_COMP) exec php-fpm

# Executables
PHP      = $(PHP_CONT) php
COMPOSER = $(PHP_CONT) composer
SYMFONY  = $(PHP_CONT) bin/console

PHP_WC      = php
COMPOSER_WC = composer
SYMFONY_WC  = bin/console

GEN_DB_PASS       = $(shell xxd -l10 -ps /dev/urandom)
GEN_APP_SECRET    = $(shell xxd -l16 -ps /dev/urandom)

up: # Start application
	$(DOCKER_COMP) up -d

down: # Stop application
	@$(DOCKER_COMP) down --remove-orphans

restart: down up # Restart application

init: .env.local up composer migrations create-admin cc

init_within_container: composer_within_container migrations_within_container import_data_within_container cc_within_container
migrations: # Run database migrations
	@$(SYMFONY) doctrine:migrations:migrate -n

migrations_within_container: # Run database migrations but from within container
	@$(SYMFONY_WC) doctrine:migrations:migrate -n

create-admin: # Create admin user
	@$(SYMFONY) app:create-user --admin

composer: # Install vendor
	@$(COMPOSER) install

composer_within_container: # Install vendor but from within container
	@$(COMPOSER_WC) install

cc: # Clear caches
	@$(SYMFONY) cache:clear
	@$(SYMFONY) cache:warmup

cc_within_container: # Clear caches but from within container
	@$(SYMFONY_WC) cache:clear
	@$(SYMFONY_WC) cache:warmup

import_data: # setup user and project from seed data
	@$(SYMFONY) app:create-user --admin ${ADMIN_NAME} ${ADMIN_EMAIL} ${ADMIN_PASSWORD} || echo "Username already exists"
	@$(SYMFONY) app:create-project ${ADMIN_EMAIL} SES_MAILER_PROJECT ses || echo "Project already exists"

import_data_within_container: # setup user and project from seed data but from within container
	@$(SYMFONY_WC) app:create-user --admin ${ADMIN_NAME} ${ADMIN_EMAIL} ${ADMIN_PASSWORD} || echo "Username already exists"
	@$(SYMFONY_WC) app:create-project ${ADMIN_EMAIL} SES_MAILER_PROJECT ses || echo "Project already exists"

upgrade: composer migrations restart

.env.local:
	@cp .env .env.local && sed -i -e 's/%CHANGE_ME_DB_PASSWORD%/$(GEN_DB_PASS)/g' .env.local && sed -i -e 's/%CHANGE_ME_APP_SECRET%/$(GEN_APP_SECRET)/g' .env.local
