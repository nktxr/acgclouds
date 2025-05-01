
CURRENT_UID:=$(shell id -u)
CURRENT_GID:=$(shell id -g)

DOCKER_COMPOSE_PULL := $(shell docker compose pull || true 2 > /dev/null > /dev/null)
DOCKER_COMPOSE := docker compose run --user="$(CURRENT_UID)"

TF := $(DOCKER_COMPOSE) terraform


.PHONY: lint
lint: 
	$(TF) fmt -check -recursive /opt/app/
