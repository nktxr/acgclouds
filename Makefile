DOCKER_COMPOSE_PULL := $(shell docker compose pull || true 2 > /dev/null > /dev/null)
DOCKER_COMPOSE := docker compose run --user="$(shell id -u)"

TF := $(DOCKER_COMPOSE) terraform
TF_ARTIFACT := /opt/app/terraform.plan


.PHONY: lint
lint:  _clean
	$(TF) fmt -check -recursive /opt/app/

.PHONY: build
build: _init ## Generate a terraform plan as an output file
	$(TF) plan -input=false -detailed-exitcode -out $(TF_ARTIFACT) \
	|| ( (($$? == 2)) && $(TF) show $(TF_ARTIFACT) > tf_plan_changes || exit 1 )

.PHONY: _init
_init:   ## Initialise terraform state file with S3 - no lock
	echo "Initialising Terraform backend with config key=tfstate/localstack.tfstate" ;\
	$(TF) init -backend-config=key=tfstate/localstack.tfstate \
		-backend-config=bucket=njttestbucket021093 \
		-reconfigure >&2 ;\

.PHONY: _clean
_clean: ## Remove terraform directory and any left over docker networks
	>&2 echo "Removing .terraform directory and purging orphaned docker networks"
	$(DOCKER_COMPOSE) --entrypoint="rm -rf .terraform/modules" terraform
	docker compose down --remove-orphans 2>/dev/null ;\
	echo "Cleanup completed."
