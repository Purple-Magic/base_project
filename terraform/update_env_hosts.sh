#!/bin/bash

set -euo pipefail

ENVIRONMENT="${1:-}"
ENV_FILE="${2:-.env}"

if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <production|staging> [env_file]"
  exit 1
fi

terraform -chdir=terraform workspace select "$ENVIRONMENT" >/dev/null

# Get IP and subdomain from terraform output
MAIN_IP=$(terraform -chdir=terraform output -raw main_host_ip)
SUBDOMAIN_URL=$(terraform -chdir=terraform output -raw subdomain_url)

if [ ! -f "$ENV_FILE" ]; then
  echo "$ENV_FILE not found"
  exit 1
fi

# Update or add the keys
sed -i "s/^MAIN_HOST=.*/MAIN_HOST=$MAIN_IP/" "$ENV_FILE" || echo "MAIN_HOST=$MAIN_IP" >> "$ENV_FILE"
sed -i "s/^HOST=.*/HOST=$SUBDOMAIN_URL/" "$ENV_FILE" || echo "HOST=$SUBDOMAIN_URL" >> "$ENV_FILE"
sed -i "s/^DB_HOST=.*/DB_HOST=$MAIN_IP/" "$ENV_FILE" || echo "DB_HOST=$MAIN_IP" >> "$ENV_FILE"

echo "✅ .env updated with MAIN_HOST: $MAIN_IP, HOST: $SUBDOMAIN_URL, DB_HOST: $MAIN_IP"
