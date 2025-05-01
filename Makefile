DOCKER_COMPOSE_PULL := $(shell docker compose pull || true 2 > /dev/null > /dev/null)
DOCKER_COMPOSE := docker compose run --user="$(shell id -u)"

TF := $(DOCKER_COMPOSE) terraform


.PHONY: lint
lint: 
	$(TF) fmt -check -recursive /opt/app/
