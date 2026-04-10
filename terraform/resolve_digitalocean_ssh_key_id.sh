#!/usr/bin/env bash

set -euo pipefail

environment="${1:-}"

if [[ -z "$environment" ]]; then
  echo "Usage: $0 <production|staging>" >&2
  exit 1
fi

vault_prefix="${ONEPASSWORD_VAULT_PREFIX:-base_project}"
vault="${vault_prefix}_${environment}"
digitalocean_item="${ONEPASSWORD_DIGITALOCEAN_ITEM:-DigitalOcean Terraform}"
ssh_key_name_item="${ONEPASSWORD_SSH_KEY_NAME_ITEM:-Terraform SSH Key Name}"

for required_command in op curl jq; do
  if ! command -v "$required_command" >/dev/null 2>&1; then
    echo "Missing required command: $required_command" >&2
    exit 1
  fi
done

if ! op vault get "$vault" >/dev/null 2>&1; then
  echo "1Password vault '$vault' was not found." >&2
  echo "Expected vault name format: '${vault_prefix}_${environment}'." >&2
  exit 1
fi

digitalocean_item_json="$(op item get "$digitalocean_item" --vault "$vault" --format json 2>/dev/null || true)"
ssh_key_name_item_json="$(op item get "$ssh_key_name_item" --vault "$vault" --format json 2>/dev/null || true)"

if [[ -z "$digitalocean_item_json" ]]; then
  echo "1Password item '$digitalocean_item' was not found in vault '$vault'." >&2
  exit 1
fi

if [[ -z "$ssh_key_name_item_json" ]]; then
  echo "1Password item '$ssh_key_name_item' was not found in vault '$vault'." >&2
  exit 1
fi

digitalocean_token="$(jq -r '.fields[] | select(.label == "credential") | .value' <<<"$digitalocean_item_json")"
ssh_key_name="$(jq -r '.fields[] | select(.label == "password") | .value' <<<"$ssh_key_name_item_json")"

if [[ -z "$digitalocean_token" || "$digitalocean_token" == "null" ]]; then
  echo "1Password item '$digitalocean_item' in vault '$vault' does not have a value in the 'credential' field." >&2
  echo "Save a DigitalOcean API token in the API Credential item's 'credential' field." >&2
  exit 1
fi

if [[ -z "$ssh_key_name" || "$ssh_key_name" == "null" ]]; then
  echo "1Password item '$ssh_key_name_item' in vault '$vault' does not have a value in the 'password' field." >&2
  echo "Save the DigitalOcean SSH key name from the DigitalOcean dashboard in the Password item's 'password' field." >&2
  exit 1
fi

do_account_response="$(curl -sS \
  -H "Authorization: Bearer $digitalocean_token" \
  -H "Content-Type: application/json" \
  "https://api.digitalocean.com/v2/account")"

do_account_id="$(jq -r '.account.uuid // empty' <<<"$do_account_response")"

if [[ -z "$do_account_id" ]]; then
  do_account_message="$(jq -r '.message // "DigitalOcean rejected the token."' <<<"$do_account_response")"
  echo "DigitalOcean token check failed for vault '$vault' item '$digitalocean_item'." >&2
  echo "$do_account_message" >&2
  exit 1
fi

do_keys_response="$(curl -sS \
  -H "Authorization: Bearer $digitalocean_token" \
  -H "Content-Type: application/json" \
  "https://api.digitalocean.com/v2/account/keys?per_page=200")"

do_keys_message="$(jq -r '.message // empty' <<<"$do_keys_response")"
if [[ -n "$do_keys_message" ]]; then
  echo "DigitalOcean SSH key lookup failed." >&2
  echo "$do_keys_message" >&2
  exit 1
fi

matching_do_keys="$(jq --arg ssh_key_name "$ssh_key_name" '
  [
    .ssh_keys[]?
    | select(.name == $ssh_key_name)
    | { id: (.id | tostring), fingerprint: .fingerprint, name: .name }
  ]
' <<<"$do_keys_response")"

matching_do_key_count="$(jq 'length' <<<"$matching_do_keys")"

if [[ "$matching_do_key_count" -lt 1 ]]; then
  echo "No DigitalOcean SSH key matched the name '$ssh_key_name' from '$ssh_key_name_item'." >&2
  echo "Save the exact SSH key name shown in the DigitalOcean dashboard for a key already uploaded to your account." >&2
  exit 1
fi

if [[ "$matching_do_key_count" -gt 1 ]]; then
  echo "Multiple DigitalOcean SSH keys matched the name '$ssh_key_name' from '$ssh_key_name_item'." >&2
  echo "Use a unique key name in DigitalOcean, then save that exact name in 1Password." >&2
  jq -r '.[] | "Matched key: id=\(.id), fingerprint=\(.fingerprint), name=\(.name)"' <<<"$matching_do_keys" >&2
  exit 1
fi

jq -r '.[0].id' <<<"$matching_do_keys"
