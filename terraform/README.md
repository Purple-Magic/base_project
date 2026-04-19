# Terraform Secrets via 1Password

Terraform in this project reads provider credentials from 1Password instead of `*.tfvars` files.

## Required 1Password items

Store all Terraform items in the 1Password vault for the current environment. By default, Terraform builds the vault name as
`base_project_<environment>`, for example:

- `base_project_staging`
- `base_project_production`

Inside that environment-specific vault, Terraform looks for:

- `DigitalOcean Terraform`
- `Cloudflare Terraform`
- `Terraform Domain`
- `Terraform SSH Key Name`

Use the `API Credential` item type for these items so Terraform can read the token from the `credential` field:

- `DigitalOcean Terraform`
- `Cloudflare Terraform`

Use the `Password` item type for these items so Terraform can read the value from the `password` field:

- `Terraform Domain`
- `Terraform SSH Key Name`

Terraform reads `DigitalOcean Terraform` and `Cloudflare Terraform` ephemerally because provider tokens can stay out of state.
It reads `Terraform Domain` through the normal `onepassword_item` data source because Terraform must
persist that value in state when it is used as a normal input and output.
The DigitalOcean SSH key name is read before Terraform apply, resolved to a real DigitalOcean SSH key ID automatically, and then
passed to Terraform as a normal input variable.

Recommended values:

- `DigitalOcean Terraform`: DigitalOcean API token
- `Cloudflare Terraform`: Cloudflare API token
- `Terraform Domain`: your Cloudflare zone name, for example `example.com`
- `Terraform SSH Key Name`: the exact SSH key name shown in your DigitalOcean account that this machine will use to connect to the server

`MAIN_HOST` and `HOST` do not need to exist in 1Password before `make create_new_staging` or `make create_new_production`.
Terraform derives them from the created droplet and configured domain, then `terraform/sync_1password_hosts.sh` writes both
items to the environment vault after `terraform apply` completes successfully.

`app_name` is normalized for hostname usage before Terraform creates the Droplet and DNS record. For example, `base_project`
becomes `base-project`. Non-production environments use a single-label hostname prefix such as
`staging-base-project.example.com` so the generated hostname stays compatible with standard wildcard certificate coverage like
`*.example.com`.

For `Cloudflare Terraform`, store a Cloudflare API Token, not a Global API Key. The token must be able to read the zone and
manage DNS records for the target zone. In practice, it should include permissions equivalent to `Zone:Read` and `DNS:Edit`
for the zone stored in `Terraform Domain`.

`make create_new_staging` and `make create_new_production` now stop before any provisioning work and ask you to confirm that
all deployment credentials are ready. The prompt tells you to check Rails credentials for the target environment, any other
committed deployment files your app depends on, and the environment-specific 1Password vault items `DigitalOcean Terraform`,
`Cloudflare Terraform`, `Terraform Domain`, and `Terraform SSH Key Name`. Enter `c` to continue or `a` to abort.

After that confirmation, the create commands run the preflight checks before Terraform apply. If a required token is missing,
saved in the wrong field, invalid, cannot access the configured zone, if the configured DigitalOcean SSH key name cannot be
resolved to exactly one uploaded SSH key, if a droplet with the target name already exists, or if the target Cloudflare DNS
record already exists, the command fails early with a direct message instead of continuing.

After Terraform finishes creating the infrastructure and the SSH wait completes, the create commands sync `MAIN_HOST` and
`HOST` into 1Password, then run `bin/kamal setup -d <environment>`. `DB_HOST` is not managed separately and is always set to
the same value as `MAIN_HOST`.

If you use a different vault prefix or item titles, set these Terraform variables:

- `onepassword_vault`
- `onepassword_digitalocean_item`
- `onepassword_cloudflare_item`
- `onepassword_domain_item`
- `onepassword_main_host_item`
- `onepassword_host_item`
- `onepassword_ssh_key_name_item`

## Authentication

The 1Password Terraform provider supports multiple authentication methods. Keep the auth secret out of the repo and provide it locally or in CI.

Local options:

- Sign in with the 1Password desktop app integration.
- Export `OP_SERVICE_ACCOUNT_TOKEN` before running Terraform.

CI option:

- Store `OP_SERVICE_ACCOUNT_TOKEN` in repository secrets and expose it only to Terraform jobs.

## Remaining Terraform inputs

These values still come from normal Terraform variables:

- `environment`
- `region`
- `size`
- `app_name`
