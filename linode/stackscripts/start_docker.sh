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

# <UDF name="FRONTEND_PORT" Label="Port to serve fronend on"  />

# <UDF name="DOMAIN" Label="Domain"  />
# <UDF name="EMAIL" Label="Email for certificate creation"  />

# <UDF name="VOLUME_PATH" Label="Mounted volume path"  />


# Exit with non zero when fail
set -e

# Log everything to /root/stackscript.log
#exec > /root/stackscript.log 2>&1

# Set environment variables
echo "export TAG=$TAG" >> ~/.bashrc
echo "export DB_NAME=$DB_NAME" >> ~/.bashrc
echo "export DB_USER=$DB_USER" >> ~/.bashrc
echo "export DB_PASS=\"$DB_PASS\"" >> ~/.bashrc
echo "export DB_HOST=$DB_HOST" >> ~/.bashrc
echo "export DB_PORT=$DB_PORT" >> ~/.bashrc
echo "export DEBUG=$DEBUG" >> ~/.bashrc
echo "export DJANGO_SECRET_KEY=\"$DJANGO_SECRET_KEY\"" >> ~/.bashrc
echo "export ALLOWED_HOSTS=$ALLOWED_HOSTS" >> ~/.bashrc
echo "export FRONTEND_PORT=$FRONTEND_PORT" >> ~/.bashrc

# Format volume if needed
FS=$(blkid -o value -s TYPE "$VOLUME_PATH" || true)

if [ -z "$FS" ]; then
    echo "No filesystem detected on $VOLUME_PATH. Formatting..."
    mkfs.ext4 "$VOLUME_PATH"
else
    echo "Filesystem detected on $VOLUME_PATH. No formatting needed."
fi

# Create mount point
MOUNT_DIR="/mnt/resume-volume"
mkdir -p $MOUNT_DIR


# Mount the volume
mount $VOLUME_PATH $MOUNT_DIR

# Add to /etc/fstab for automatic mounting
echo "$VOLUME_PATH $MOUNT_DIR ext4 defaults,nofail 0 2" >> /etc/fstab

# Create symbolic links to volume
mkdir -p /mnt/resume-volume/letsencrypt
sudo ln -s /mnt/resume-volume/letsencrypt /etc/letsencrypt

# Create data for postgresql
mkdir -p /mnt/resume-volume/postgresql/data

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

# Install certbot
sudo apt-get install -y certbot
certbot certonly --standalone -d $DOMAIN  -d www.$DOMAIN --email $EMAIL --agree-tos --non-interactive

# Run Docker Compose
cd /root
docker-compose up -d

# Renew certificate every day
0 3 * * * cd /root && docker-compose stop nginx && certbot renew --standalone && docker-compose start nginx
