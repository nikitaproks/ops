#!/bin/bash

# <UDF name="GITHUB_TOKEN" Label="Token for github" />

# <UDF name="DOCKERHUB_USERNAME" Label="Docker hub username" />
# <UDF name="DOCKERHUB_TOKEN" Label="Docker hub password"  />
# <UDF name="TAG" Label="Image version tag"  />


# <UDF name="DB_NAME" Label="Database name"  />
# <UDF name="DB_USER" Label="Database user"  />
# <UDF name="DB_PASS" Label="Database password"  />
# <UDF name="DB_HOST" Label="Database host"  />
# <UDF name="DB_PORT" Label="Database port"  />

# <UDF name="DEBUG" Label="Django debug option"  />
# <UDF name="DJANGO_SECRET_KEY" Label="Django secret key"  />
# <UDF name="ALLOWED_HOSTS" Label="Django allowed hosts"  />

# <UDF name="DJANGO_SUPERUSER_USERNAME" Label="Django superuser username"  />
# <UDF name="DJANGO_SUPERUSER_EMAIL" Label="Django superuser email"  />
# <UDF name="DJANGO_SUPERUSER_PASSWORD" Label="Django superuser password"  />


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
curl -H "Authorization: token $GITHUB_TOKEN" -L https://raw.githubusercontent.com/nikitaproks/resume/main/docker-compose.yml -o /root/docker-compose.yml
curl -H "Authorization: token $GITHUB_TOKEN" -L https://raw.githubusercontent.com/nikitaproks/resume/main/nginx.conf -o /root/nginx.conf

# # Run Docker Compose
cd /root
docker-compose up -d
