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

define confirm_create_requirements
	@printf '\033[1;33m%s\033[0m\n' "Before provisioning '$(1)', confirm that all required deployment credentials are ready."; \
	printf '\033[1;36m%s\033[0m\n' "1. Save Rails credentials for $(1)."; \
	printf '%s\n' "Edit them with: dip rails credentials:edit"; \
	printf '%s\n' "For this environment use: dip bin/rails credentials:edit --environment $(1)"; \
	printf '%s\n' "Example credentials structure:"; \
	printf '\033[0;32m%s\033[0m\n' "$(1):"; \
	printf '\033[0;32m%s\033[0m\n' "  database:"; \
	printf '\033[0;32m%s\033[0m\n' "    host: db"; \
	printf '\033[0;32m%s\033[0m\n' "    username: # username you want"; \
	printf '\033[0;32m%s\033[0m\n' "    password: # password you want"; \
	printf '\033[0;32m%s\033[0m\n' "    primary:"; \
	printf '\033[0;32m%s\033[0m\n' "      name: # database name you want. Primary database contains project data"; \
	printf '\033[0;32m%s\033[0m\n' "    cable:"; \
	printf '\033[0;32m%s\033[0m\n' "      name: # database name you want. Cable database contains ActionCable data (WebSocket logic)"; \
	printf '\033[0;32m%s\033[0m\n' "    queue:"; \
	printf '\033[0;32m%s\033[0m\n' "      name: # database name you want. Queue database contains ActiveJob data (Background job logic)"; \
	printf '\033[0;32m%s\033[0m\n' "    cache:"; \
	printf '\033[0;32m%s\033[0m\n' "      name: # database name you want. Cache database contains caching data (Cache logic)"; \
	printf '\033[1;36m%s\033[0m\n' "2. Check any other committed deployment files your app needs."; \
	printf '\033[1;36m%s\033[0m\n' "3. Check 1Password vault 'base_project_$(1)' and make sure these items are filled:"; \
	printf '%s\n' "   - DigitalOcean Terraform: DigitalOcean API Token"; \
	printf '%s\n' "   - Cloudflare Terraform: Cloudflare API Token"; \
	printf '%s\n' "   - Terraform Domain: the deployment domain"; \
	printf '%s\n' "   - Terraform SSH Key Name: the exact DigitalOcean SSH key name that this machine will use to connect to the server"; \
	printf '%s\n' "   Save API tokens in the 'credential' field."; \
	printf '%s\n' "   Save the domain and SSH key name in the 'password' field."; \
	printf '%s\n' "4. If your app depends on anything else for deploys, fill that now too."; \
	read -r -p "Type 'c' to continue or 'a' to abort: " confirmation; \
	if [[ "$$confirmation" == "a" || "$$confirmation" == "A" ]]; then \
		echo "Create was aborted."; \
		echo "Fill the missing credentials, then run 'make $(2)' again."; \
		exit 1; \
	fi; \
	if [[ "$$confirmation" != "c" && "$$confirmation" != "C" ]]; then \
		echo "Expected 'c' or 'a'. Aborting."; \
		exit 1; \
	fi
endef

create_new_production:
	$(call confirm_create_requirements,production,create_new_production)
	@$(MAKE) terraform_init
	$(call terraform_preflight,production,create)
	$(call ensure_workspace,production)
	@$(TF) apply -auto-approve -var="environment=production" -var="ssh_key_identifier=$(call terraform_ssh_key_identifier,production)"
	$(call sync_1password_hosts,production)
	$(call kamal_setup,production)

create_new_staging:
	$(call confirm_create_requirements,staging,create_new_staging)
	@$(MAKE) terraform_init
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
