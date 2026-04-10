#!/usr/bin/env bash

set -euo pipefail

environment="${1:-}"

if [[ -z "$environment" ]]; then
  echo "Usage: $0 <production|staging>" >&2
  exit 1
fi

app_name="${TF_VAR_app_name:-base_project}"
hostname_app_name="$(tr '[:upper:]' '[:lower:]' <<<"$app_name" | sed -E 's/[^a-z0-9-]/-/g')"

if [[ "$environment" == "production" ]]; then
  echo "$hostname_app_name"
else
  echo "${hostname_app_name}-${environment}"
fi
