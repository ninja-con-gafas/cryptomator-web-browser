#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="cryptomator"

if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

if ! docker ps --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  docker run -d \
  --rm \
  --name cryptomator \
  --privileged \
  --device /dev/fuse:/dev/fuse \
  -p 8080:80 \
  -v "${VAULT_PATH}:/vault:rw" \
  cryptomator-cli:0.6.2
else
  echo "Container '${CONTAINER_NAME}' is already running."
  exit 0
fi

MOUNT_POINT="/mnt/drive"
VAULT_PATH="/vault"

echo "Unlocking vault $VAULT_PATH and mounting to $MOUNT_POINT"

read -r -s -p "Enter Cryptomator vault password: " VAULT_PASSWORD
echo

docker exec -i "$CONTAINER_NAME" filebrowser -r /mnt/drive --address 0.0.0.0 --port 80 &

printf '%s' "$VAULT_PASSWORD" | docker exec -i "$CONTAINER_NAME" sh -c "
  mkdir -p \"$MOUNT_POINT\" &&
  cryptomator unlock \
    --password:stdin \
    --mounter=org.cryptomator.frontend.fuse.mount.LinuxFuseMountProvider \
    --mountPoint=\"$MOUNT_POINT\" \
    \"$VAULT_PATH\"
" &