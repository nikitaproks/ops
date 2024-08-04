#!/bin/bash

# <UDF name="GITHUB_TOKEN" Label="Token for github" />
# <UDF name="DOCKERHUB_USERNAME" Label="Docker hub username" />
# <UDF name="DOCKERHUB_TOKEN" Label="Docker hub password"  />
# <UDF name="BOT_API_KEY" Label="Telegram bot token"  />
# <UDF name="API_KEY_LINODE" Label="API key for linode"  />
# <UDF name="SHADOWSOCKS_PASSWORD" Label="Password for shadowsocks"  />

# <UDF name="STACKSCRIPT_ID" Label="ID of stackscript to use"  />
# <UDF name="ALLOWED_CHAT_IDS" Label="Allowed chats to access the bot"  />
# <UDF name="TAG" Label="Image version tag"  />



# Exit with non zero when fail
set -e

# Update and install Docker
apt-get update
apt-get install -y docker.io

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Start Docker
systemctl enable docker
systemctl stop docker
systemctl start docker

echo "$DOCKERHUB_TOKEN" | docker login --username $DOCKERHUB_USERNAME --password-stdin

# Download docker-compose.yml from GitHub
PROTOCOL="https"
URL="://raw.githubusercontent.com/nikitaproks/vpn_bot/main/docker-compose.yml"
FULL_URL="$PROTOCOL$URL"
curl -H "Authorization: token $GITHUB_TOKEN" -o /root/docker-compose.yml  -SL $FULL_URL

# Run Docker Compose
cd /root
docker-compose up -d
