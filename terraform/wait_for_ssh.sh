#!/bin/bash

set -euo pipefail

HOST="$1"
PORT="${2:-22}"
DROPLET_ID="$3"
INITIAL_SLEEP_TIME=60
SSH_CHECK_ATTEMPTS=30
LOCK_CHECK_ATTEMPTS=60
CHECK_INTERVAL=5
SSH_OPTIONS=(
  -o BatchMode=yes
  -o StrictHostKeyChecking=accept-new
  -o ConnectTimeout=5
  -p "$PORT"
)

echo "Waiting for Droplet $DROPLET_ID to become active..."

while true; do
  status="$(doctl compute droplet get "$DROPLET_ID" --format Status --no-header)"

  if [[ "$status" == "active" ]]; then
    echo "Droplet is active."
    sleep "$INITIAL_SLEEP_TIME"
    break
  fi

  echo "Droplet status is '$status'. Waiting..."
  sleep "$CHECK_INTERVAL"
done

echo "Waiting for SSH port on $HOST:$PORT..."

for attempt in $(seq 1 "$SSH_CHECK_ATTEMPTS"); do
  if nc -z "$HOST" "$PORT"; then
    echo "SSH port is reachable on $HOST:$PORT."
    break
  fi

  if [[ "$attempt" == "$SSH_CHECK_ATTEMPTS" ]]; then
    echo "SSH port did not become reachable after $SSH_CHECK_ATTEMPTS attempts." >&2
    exit 1
  fi

  echo "Attempt $attempt/$SSH_CHECK_ATTEMPTS: SSH port not ready. Waiting $CHECK_INTERVAL seconds..."
  sleep "$CHECK_INTERVAL"
done

echo "Waiting for SSH command execution on $HOST..."

for attempt in $(seq 1 "$SSH_CHECK_ATTEMPTS"); do
  if ssh "${SSH_OPTIONS[@]}" "root@$HOST" "exit 0" >/dev/null 2>&1; then
    echo "SSH login is ready on $HOST."
    break
  fi

  if [[ "$attempt" == "$SSH_CHECK_ATTEMPTS" ]]; then
    echo "SSH login did not become ready after $SSH_CHECK_ATTEMPTS attempts." >&2
    exit 1
  fi

  echo "Attempt $attempt/$SSH_CHECK_ATTEMPTS: SSH login not ready. Waiting $CHECK_INTERVAL seconds..."
  sleep "$CHECK_INTERVAL"
done

echo "Waiting for /var/lib/dpkg/lock-frontend to be released on $HOST..."

for attempt in $(seq 1 "$LOCK_CHECK_ATTEMPTS"); do
  if ssh "${SSH_OPTIONS[@]}" "root@$HOST" "bash -lc '
set -euo pipefail

if pgrep -x dpkg >/dev/null 2>&1; then
  exit 1
fi

exit 0
'" >/dev/null 2>&1; then
    echo "apt, dpkg, and lock files are clear on $HOST."
    exit 0
  fi

  if [[ "$attempt" == "$LOCK_CHECK_ATTEMPTS" ]]; then
    echo "apt/dpkg initialization stayed busy after $LOCK_CHECK_ATTEMPTS attempts." >&2
    exit 1
  fi

  echo "Attempt $attempt/$LOCK_CHECK_ATTEMPTS: apt/dpkg is still busy. Waiting $CHECK_INTERVAL seconds..."
  sleep "$CHECK_INTERVAL"
done
