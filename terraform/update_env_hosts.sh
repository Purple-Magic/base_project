#!/bin/bash

set -euo pipefail

# Get IP and subdomain from terraform output
MAIN_IP=$(terraform -chdir=terraform output -raw main_host_ip)
SUBDOMAIN_URL=$(terraform -chdir=terraform output -raw subdomain_url)

# Path to .env file
ENV_FILE=".env"

# Ensure the .env file exists
if [ ! -f "$ENV_FILE" ]; then
  echo "$ENV_FILE not found"
  exit 1
fi

# Update or add the keys
sed -i "s/^MAIN_HOST=.*/MAIN_HOST=$MAIN_IP/" "$ENV_FILE" || echo "MAIN_HOST=$MAIN_IP" >> "$ENV_FILE"
sed -i "s/^DB_HOST=.*/DB_HOST=$MAIN_IP/" "$ENV_FILE" || echo "DB_HOST=$MAIN_IP" >> "$ENV_FILE"

sed -i "s/^HOST=.*/HOST=$SUBDOMAIN_URL/" "$ENV_FILE" || echo "HOST=$SUBDOMAIN_URL" >> "$ENV_FILE"

echo "✅ .env updated with IP: $MAIN_IP and Subdomain: $SUBDOMAIN_URL"
