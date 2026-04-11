#!/usr/bin/env bash

set -euo pipefail

environment="${1:-}"
mode="${2:-create}"

if [[ -z "$environment" ]]; then
  echo "Usage: $0 <production|staging> [create|destroy]" >&2
  exit 1
fi

vault_prefix="${ONEPASSWORD_VAULT_PREFIX:-base_project}"
vault="${vault_prefix}_${environment}"
digitalocean_item="${ONEPASSWORD_DIGITALOCEAN_ITEM:-DigitalOcean Terraform}"
cloudflare_item="${ONEPASSWORD_CLOUDFLARE_ITEM:-Cloudflare Terraform}"
domain_item="${ONEPASSWORD_DOMAIN_ITEM:-Terraform Domain}"
app_name="${TF_VAR_app_name:-base_project}"
droplet_name="$(./terraform/resolve_droplet_name.sh "$environment")"

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
cloudflare_item_json="$(op item get "$cloudflare_item" --vault "$vault" --format json 2>/dev/null || true)"
domain_item_json="$(op item get "$domain_item" --vault "$vault" --format json 2>/dev/null || true)"
if [[ -z "$digitalocean_item_json" ]]; then
  echo "1Password item '$digitalocean_item' was not found in vault '$vault'." >&2
  exit 1
fi

if [[ -z "$cloudflare_item_json" ]]; then
  echo "1Password item '$cloudflare_item' was not found in vault '$vault'." >&2
  exit 1
fi

if [[ -z "$domain_item_json" ]]; then
  echo "1Password item '$domain_item' was not found in vault '$vault'." >&2
  exit 1
fi

digitalocean_token="$(jq -r '.fields[] | select(.label == "credential") | .value' <<<"$digitalocean_item_json")"
cloudflare_token="$(jq -r '.fields[] | select(.label == "credential") | .value' <<<"$cloudflare_item_json")"
domain="$(jq -r '.fields[] | select(.label == "password") | .value' <<<"$domain_item_json")"

if [[ -z "$digitalocean_token" || "$digitalocean_token" == "null" ]]; then
  echo "1Password item '$digitalocean_item' in vault '$vault' does not have a value in the 'credential' field." >&2
  echo "Save a DigitalOcean API token in the API Credential item's 'credential' field." >&2
  exit 1
fi

if [[ -z "$cloudflare_token" || "$cloudflare_token" == "null" ]]; then
  echo "1Password item '$cloudflare_item' in vault '$vault' does not have a value in the 'credential' field." >&2
  echo "Save a Cloudflare API Token in the API Credential item's 'credential' field." >&2
  exit 1
fi

if [[ -z "$domain" || "$domain" == "null" ]]; then
  echo "1Password item '$domain_item' in vault '$vault' does not have a value in the 'password' field." >&2
  echo "Save the Cloudflare zone name, such as 'example.com', in the Password item's 'password' field." >&2
  exit 1
fi

./terraform/resolve_digitalocean_ssh_key_id.sh "$environment" >/dev/null

do_droplets_response="$(curl -sS \
  -H "Authorization: Bearer $digitalocean_token" \
  -H "Content-Type: application/json" \
  "https://api.digitalocean.com/v2/droplets?per_page=200")"

do_droplets_message="$(jq -r '.message // empty' <<<"$do_droplets_response")"
if [[ -n "$do_droplets_message" ]]; then
  echo "DigitalOcean droplet lookup failed." >&2
  echo "$do_droplets_message" >&2
  exit 1
fi

matching_droplet_count="$(jq --arg droplet_name "$droplet_name" '
  [
    .droplets[]?
    | select(.name == $droplet_name)
  ] | length
' <<<"$do_droplets_response")"

if [[ "$mode" == "create" && "$matching_droplet_count" -gt 0 ]]; then
  echo "A DigitalOcean droplet named '$droplet_name' already exists." >&2
  echo "Create was stopped to avoid colliding with an existing droplet. Remove or rename the existing droplet, or change app_name/environment. If you are totally sure the existing droplet was created via this toolset, you can run 'make destroy_staging' first." >&2
  exit 1
fi

verify_response="$(curl -sS \
  -H "Authorization: Bearer $cloudflare_token" \
  -H "Content-Type: application/json" \
  "https://api.cloudflare.com/client/v4/user/tokens/verify")"

verify_success="$(jq -r '.success // false' <<<"$verify_response")"

if [[ "$verify_success" != "true" ]]; then
  verify_message="$(jq -r 'first(.errors[]?.message) // "Cloudflare rejected the token."' <<<"$verify_response")"

  echo "Cloudflare token check failed for vault '$vault' item '$cloudflare_item'." >&2
  echo "$verify_message" >&2
  echo "Expected: a Cloudflare API Token in the 'credential' field, not a Global API Key." >&2
  echo "Required permissions: Zone:Read and DNS:Edit for the zone stored in '$domain_item'." >&2
  exit 1
fi

zones_response="$(curl -sS -G \
  -H "Authorization: Bearer $cloudflare_token" \
  -H "Content-Type: application/json" \
  --data-urlencode "name=$domain" \
  --data-urlencode "per_page=1" \
  "https://api.cloudflare.com/client/v4/zones")"

zones_success="$(jq -r '.success // false' <<<"$zones_response")"

if [[ "$zones_success" != "true" ]]; then
  zones_message="$(jq -r 'first(.errors[]?.message) // "Cloudflare could not list zones for this token."' <<<"$zones_response")"

  echo "Cloudflare zone lookup failed for domain '$domain'." >&2
  echo "$zones_message" >&2
  echo "Check that the token in '$cloudflare_item' can read zones and that '$domain_item' contains the correct zone name." >&2
  exit 1
fi

zone_count="$(jq '.result | length' <<<"$zones_response")"

if [[ "$zone_count" -lt 1 ]]; then
  echo "Cloudflare token is valid, but no accessible zone matched '$domain'." >&2
  echo "Check the value in '$domain_item' and confirm the token can access that zone." >&2
  exit 1
fi
