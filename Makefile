SHELL := /bin/bash
GIT := /usr/bin/env git
PYTHON := /usr/bin/env python3
DIR := ${CURDIR}
TF_OPTS ?=

CURRENT_UID := $(shell id -u)
CURRENT_GID := $(shell id -g)
GENERATE_PASSWD_RESULT:=$(shell $(DOCKER_COMPOSE) -e USER_ID=$(CURRENT_UID) -e GROUP_ID=$(CURRENT_GID)  passwd-gen > passwd)

DOCKER_COMPOSE_PULL := $(shell docker -l error compose pull || true 2 > /dev/null > /dev/null)
DOCKER_COMPOSE := docker -l error compose run --user="$(CURRENT_UID)"

TF := $(DOCKER_COMPOSE) terraform


.PHONY: lint
lint: _clean
	$(TF) fmt -check -recursive /opt/app/

.PHONY: _clean
_clean:
	>&2 echo "Removing .terraform directory and purging orphaned docker networks"
	$(DOCKER_COMPOSE) --entrypoint="rm -rf .terraform/modules" terraform
	docker compose down --remove-orphans 2>/dev/null