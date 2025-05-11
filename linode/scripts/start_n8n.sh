#!/bin/bash
set -e

# Define your environment variables
export POSTGRES_HOST="$1"
export POSTGRES_PORT="$2"
export POSTGRES_USER="$3"
export POSTGRES_PASSWORD="$4"

export DOMAIN="$5"
export MOUNT_DIR="$6"


export N8N_PERSISTENT_PATH="${MOUNT_DIR}/n8n"
export CADDY_DATA_PERSISTENT_PATH="${MOUNT_DIR}/caddy/data"
export CADDY_CONFIG_PERSISTENT_PATH="${MOUNT_DIR}/caddy/config"

# Create directories for persistent volumes
mkdir -p "${N8N_PERSISTENT_PATH}"
mkdir -p "${CADDY_DATA_PERSISTENT_PATH}"
mkdir -p "${CADDY_CONFIG_PERSISTENT_PATH}"

sudo chmod -R 777 ${N8N_PERSISTENT_PATH}

docker network create n8n_net || echo "Network 'n8n_net' already exists."

docker run -it -d \
 --name n8n \
 --restart unless-stopped \
 --network n8n_net \
 -e DB_TYPE=postgresdb \
 -e DB_POSTGRESDB_HOST="${POSTGRES_HOST}" \
 -e DB_POSTGRESDB_PORT="${POSTGRES_PORT}" \
 -e DB_POSTGRESDB_USER="${POSTGRES_USER}" \
 -e DB_POSTGRESDB_PASSWORD="${POSTGRES_PASSWORD}"    \
 -e DB_POSTGRESDB_SCHEMA=n8n_schema \
 -e DB_POSTGRESDB_SSL_CA_FILE="/tmp/self-hosted-database-ca-certificate.crt" \
 -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
 -e DB_POSTGRESDB_SSL_ENABLED=true \
 -e DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=true \
 -e N8N_RUNNERS_ENABLED=true \
 -e GENERIC_TIMEZONE="Europe/Berlin" \
 -e TZ="Europe/Berlin" \
 -e N8N_HOST="${DOMAIN}" \
 -e N8N_PORT=5678 \
 -e N8N_PROTOCOL=https \
 -e WEBHOOK_URL=https://${DOMAIN}/ \
 -e N8N_EDITOR_BASE_URL=https://${DOMAIN}/ \
 -v /tmp/self-hosted-database-ca-certificate.crt:/tmp/self-hosted-database-ca-certificate.crt \
 -v "${N8N_PERSISTENT_PATH}:/home/node/.n8n" \
 docker.n8n.io/n8nio/n8n


CADDY_CONFIG="$DOMAIN {
    reverse_proxy n8n:5678
}"

# Write the Caddyfile to the mounted directory
echo "$CADDY_CONFIG" > "${CADDY_CONFIG_PERSISTENT_PATH}/Caddyfile"

# Run Caddy container with inline config
docker run -d \
  --name caddy \
  --restart always \
  --network n8n_net \
  -p 80:80 -p 443:443 \
  -v "${CADDY_DATA_PERSISTENT_PATH}:/data" \
  -v "${CADDY_CONFIG_PERSISTENT_PATH}:/config" \
  -v "${CADDY_CONFIG_PERSISTENT_PATH}/Caddyfile:/etc/caddy/Caddyfile" \
  caddy:latest
