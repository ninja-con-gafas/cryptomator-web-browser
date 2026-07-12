#!/usr/bin/env bash
set -euo pipefail

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

TTYD_PASSWORD="$(openssl rand -base64 24 | cut -c1-24)"

if ! docker ps --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  docker run -d \
  --rm \
  --name "$CONTAINER_NAME" \
  --device /dev/fuse:/dev/fuse \
  --cap-add SYS_ADMIN \
  --device /dev/fuse:/dev/fuse \
  --security-opt apparmor:unconfined \
  -p 7681:7681 \
  -p 8080:8080 \
  -e TTYD_PASSWORD="$TTYD_PASSWORD" \
  -v "${VAULT_PATH}:/mnt/vault:rw" \
  "$CONTAINER_IMAGE"
else
  echo "Container '${CONTAINER_NAME}' is already running."
  exit 0
fi

echo "Unlocking vault $VAULT_PATH and mounting to /mnt/drive"

read -r -s -p "Enter Cryptomator vault password: " VAULT_PASSWORD
echo

printf '%s' "$VAULT_PASSWORD" | docker exec -i "$CONTAINER_NAME" sh -c "
  cryptomator unlock \
    --password:stdin \
    --mounter=org.cryptomator.frontend.fuse.mount.LinuxFuseMountProvider \
    --mountPoint=/mnt/drive \
    /mnt/vault
" &

sleep 3

echo "Filebrowser user:admin password: $(docker logs "$CONTAINER_NAME" 2>&1 | awk -F'password: ' '/randomly generated password:/ {print $2; exit}')"
echo "ttyd user:browser password: $TTYD_PASSWORD"