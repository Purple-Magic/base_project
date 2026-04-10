#!/usr/bin/env bash

set -euo pipefail

environment="${1:-}"

if [[ -z "$environment" ]]; then
  echo "Usage: $0 <production|staging>" >&2
  exit 1
fi

for required_command in terraform kamal; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "Missing required command: $required_command" >&2
    exit 1
  fi
done

terraform -chdir=terraform workspace select "$environment" >/dev/null

main_host="$(terraform -chdir=terraform output -raw main_host_ip)"
droplet_id="$(terraform -chdir=terraform output -raw droplet_id)"
subdomain_url="$(terraform -chdir=terraform output -raw subdomain_url)"

if [[ -z "$main_host" ]]; then
  echo "Terraform output 'main_host_ip' resolved to an empty value for workspace '$environment'." >&2
  exit 1
fi

if [[ -z "$droplet_id" ]]; then
  echo "Terraform output 'droplet_id' resolved to an empty value for workspace '$environment'." >&2
  exit 1
fi

if [[ -z "$subdomain_url" ]]; then
  echo "Terraform output 'subdomain_url' resolved to an empty value for workspace '$environment'." >&2
  exit 1
fi

echo "Running Kamal setup for '$environment' with MAIN_HOST=$main_host and HOST=$subdomain_url"

./terraform/wait_for_ssh.sh "$main_host" 22 "$droplet_id"

export MAIN_HOST="$main_host"
export DB_HOST="$main_host"
export HOST="$subdomain_url"
export RAILS_ENV="$environment"

kamal setup -d "$environment"
