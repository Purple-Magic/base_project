SHELL := /bin/bash

TF_DIR := terraform
TF := terraform -chdir=$(TF_DIR)

.PHONY: terraform_init terraform_preflight create_new_production create_new_staging deploy_production deploy_staging logs_production logs_staging destroy_production destroy_staging

terraform_init:
	@$(TF) init

define terraform_preflight
	@./terraform/preflight_checks.sh $(1) $(2)
endef

define terraform_ssh_key_identifier
$$(./terraform/resolve_digitalocean_ssh_key_id.sh $(1))
endef

define terraform_droplet_name
$$(./terraform/resolve_droplet_name.sh $(1))
endef

define kamal_setup
	@./terraform/run_kamal_setup.sh $(1)
endef

define kamal_logs
	@./terraform/run_kamal_logs.sh $(1)
endef

define sync_1password_hosts
	@./terraform/sync_1password_hosts.sh $(1)
endef

define ensure_workspace
	@$(TF) workspace select $(1) >/dev/null 2>&1 || $(TF) workspace new $(1)
endef

define require_workspace
	@$(TF) workspace select $(1) >/dev/null 2>&1 || { \
		echo "Terraform workspace '$(1)' does not exist."; \
		exit 1; \
	}
endef

define confirm_destroy
	@read -r -p "Type '$(1)' to confirm destroy: " confirmation; \
	if [[ "$$confirmation" != "$(1)" ]]; then \
		echo "Confirmation did not match '$(1)'. Aborting."; \
		exit 1; \
	fi
endef

create_new_production: terraform_init
	$(call terraform_preflight,production,create)
	$(call ensure_workspace,production)
	@$(TF) apply -auto-approve -var="environment=production" -var="ssh_key_identifier=$(call terraform_ssh_key_identifier,production)"
	$(call sync_1password_hosts,production)
	$(call kamal_setup,production)

create_new_staging: terraform_init
	$(call terraform_preflight,staging,create)
	$(call ensure_workspace,staging)
	@$(TF) apply -auto-approve -var="environment=staging" -var="ssh_key_identifier=$(call terraform_ssh_key_identifier,staging)"
	$(call sync_1password_hosts,staging)
	$(call kamal_setup,staging)

deploy_production: terraform_init
	$(call require_workspace,production)
	$(call sync_1password_hosts,production)
	$(call kamal_setup,production)

deploy_staging: terraform_init
	$(call require_workspace,staging)
	$(call sync_1password_hosts,staging)
	$(call kamal_setup,staging)

logs_production: terraform_init
	$(call require_workspace,production)
	$(call sync_1password_hosts,production)
	$(call kamal_logs,production)

logs_staging: terraform_init
	$(call require_workspace,staging)
	$(call sync_1password_hosts,staging)
	$(call kamal_logs,staging)

destroy_production: terraform_init
	$(call terraform_preflight,production,destroy)
	$(call require_workspace,production)
	$(call confirm_destroy,$(call terraform_droplet_name,production))
	@$(TF) destroy -auto-approve -var="environment=production" -var="ssh_key_identifier=$(call terraform_ssh_key_identifier,production)"

destroy_staging: terraform_init
	$(call terraform_preflight,staging,destroy)
	$(call require_workspace,staging)
	$(call confirm_destroy,$(call terraform_droplet_name,staging))
	@$(TF) destroy -auto-approve -var="environment=staging" -var="ssh_key_identifier=$(call terraform_ssh_key_identifier,staging)"
