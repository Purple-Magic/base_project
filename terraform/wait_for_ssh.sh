#!/bin/bash
set -e

HOST="$1"
PORT="${2:-22}"
DROPLET_ID="$3"
SLEEP_TIME=60

echo "⏲️ Waiting for Droplet $DROPLET_ID to become active..."

# Loop until the droplet status is "active"
while true; do
  status=$(doctl compute droplet get "$DROPLET_ID" --format Status --no-header)
  
  if [ "$status" == "active" ]; then
    echo "✅ Droplet is active and ready!"

    sleep $SLEEP_TIME

    break
  else
    echo "🔄 Droplet status is '$status', waiting..."
    sleep 5
  fi
done

echo "⏲️ Waiting for SSH to become available on $HOST:$PORT..."

# Loop until SSH is available
for i in $(seq 1 20); do
  if nc -z "$HOST" "$PORT"; then
    echo "✅ SSH is ready on $HOST:$PORT"
    exit 0
  fi
  echo "Attempt $i/20: SSH not ready. Waiting 5 seconds..."
  sleep 5
done

echo "❌ SSH not accessible after multiple attempts."
exit 1

