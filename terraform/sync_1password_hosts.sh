#!/usr/bin/env bash

set -euo pipefail

environment="${1:-}"

if [[ -z "$environment" ]]; then
  echo "Usage: $0 <production|staging>" >&2
  exit 1
fi

vault_prefix="${ONEPASSWORD_VAULT_PREFIX:-base_project}"
vault="${vault_prefix}_${environment}"
main_host_item="${ONEPASSWORD_MAIN_HOST_ITEM:-MAIN_HOST}"
host_item="${ONEPASSWORD_HOST_ITEM:-HOST}"

for required_command in op terraform; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "Missing required command: $required_command" >&2
    exit 1
  fi
done

terraform -chdir=terraform workspace select "$environment" >/dev/null

main_host="$(terraform -chdir=terraform output -raw main_host_ip)"
host="$(terraform -chdir=terraform output -raw subdomain_url)"

upsert_password_item() {
  local item_title="$1"
  local item_value="$2"

  if op item get "$item_title" --vault "$vault" >/dev/null 2>&1; then
    op item edit "$item_title" --vault "$vault" "password=$item_value" >/dev/null
  else
    op item create --category=password --vault "$vault" --title "$item_title" "password=$item_value" >/dev/null
  fi
}

upsert_password_item "$main_host_item" "$main_host"
upsert_password_item "$host_item" "$host"

echo "Synced 1Password items in '$vault': $main_host_item=$main_host, $host_item=$host"
