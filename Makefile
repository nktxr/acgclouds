DOCKER_COMPOSE_PULL := $(shell docker compose pull || true 2 > /dev/null > /dev/null)
DOCKER_COMPOSE := docker compose run --user="$(shell id -u)"

TF := $(DOCKER_COMPOSE) terraform
TF_ARTIFACT := /opt/app/terraform.plan


.PHONY: lint
lint:  _clean
	$(TF) fmt -check -recursive /opt/app/
	echo "Terraform formatting check complete"

.PHONY: build
build: _init ## Generate a terraform plan as an output file
	$(TF) plan -input=false -detailed-exitcode -out $(TF_ARTIFACT) \
	|| ( (($$? == 2)) && $(TF) show $(TF_ARTIFACT) > tf_plan_changes || exit 1 )

.PHONY: apply
apply: ## Apply terraform changes
	$(TF) apply -input=false -auto-approve $(TF_ARTIFACT) || exit 1

.PHONY: _init
_init:   ## Initialise terraform state
	echo "Initialising Terraform backend" ;\
	$(TF) init -input=false -backend-config="bucket=$(BUCKET_NAME)";\

.PHONY: _clean
_clean: ## Remove terraform directory and any left over docker networks
	>&2 echo "Removing .terraform directory and purging orphaned docker networks"
	$(DOCKER_COMPOSE) --entrypoint="rm -rf .terraform/modules" terraform || true ;\
	docker compose down --remove-orphans || true ;\
	echo "Cleanup completed."
