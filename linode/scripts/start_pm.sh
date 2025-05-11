#!/bin/bash
set -e

# Define your environment variables
export ADMIN_TOKEN="$1"
export DOMAIN="$2"
export MOUNT_DIR="$3"
export VAULT_PERSISTENT_PATH="${MOUNT_DIR}/vault"
export CADDY_DATA_PERSISTENT_PATH="${MOUNT_DIR}/caddy/data"
export CADDY_CONFIG_PERSISTENT_PATH="${MOUNT_DIR}/caddy/config"

# Create directories for persistent volumes
mkdir -p "${VAULT_PERSISTENT_PATH}"
mkdir -p "${CADDY_DATA_PERSISTENT_PATH}"
mkdir -p "${CADDY_CONFIG_PERSISTENT_PATH}"

# Create Docker network
docker network create vault_net || echo "Network 'vault_net' already exists."

# Run Vaultwarden container
docker run -d \
  --name vaultwarden \
  --restart always \
  --network vault_net \
  -e ADMIN_TOKEN="$ADMIN_TOKEN" \
  -e SIGNUPS_ALLOWED=false \
  -v "${VAULT_PERSISTENT_PATH}:/data" \
  vaultwarden/server:latest

CADDY_CONFIG="$DOMAIN {
    reverse_proxy vaultwarden:80
}"

# Write the Caddyfile to the mounted directory
echo "$CADDY_CONFIG" > "${CADDY_CONFIG_PERSISTENT_PATH}/Caddyfile"

# Run Caddy container with inline config
docker run -d \
  --name caddy \
  --restart always \
  --network vault_net \
  -p 80:80 -p 443:443 \
  -v "${CADDY_DATA_PERSISTENT_PATH}:/data" \
  -v "${CADDY_CONFIG_PERSISTENT_PATH}:/config" \
  -v "${CADDY_CONFIG_PERSISTENT_PATH}/Caddyfile:/etc/caddy/Caddyfile" \
  caddy:latest
