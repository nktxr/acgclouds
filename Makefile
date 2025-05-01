
CURRENT_UID:=$(shell id -u)
CURRENT_GID:=$(shell id -g)
GENERATE_PASSWD_RESULT:=$(shell $(DOCKER_COMPOSE) -e USER_ID=$(CURRENT_UID) -e GROUP_ID=$(CURRENT_GID)  passwd-gen > passwd)

DOCKER_COMPOSE_PULL := $(shell docker -l error compose pull || true 2 > /dev/null > /dev/null)
DOCKER_COMPOSE := docker -l error compose run --user="$(CURRENT_UID)"

TF := $(DOCKER_COMPOSE) terraform


.PHONY: lint
lint: 
	$(TF) fmt -check -recursive /opt/app/
