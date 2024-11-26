#!/bin/bash
# <UDF name="VOLUME_PATH" Label="Path of the linode volume attached"  />
# <UDF name="MOUNT_DIR" Label="Path where attached linode volume should be mounted"  />

# Exit with non zero when fail
set -e

# Log everything to /root/stackscript.log
exec > /root/stackscript.log 2>&1

# Format volume if needed
FS=$(blkid -o value -s TYPE "$VOLUME_PATH" || true)

if [ -z "$FS" ]; then
    echo "No filesystem detected on $VOLUME_PATH. Formatting..."
    mkfs.ext4 "$VOLUME_PATH"
else
    echo "Filesystem detected on $VOLUME_PATH. No formatting needed."
fi

# Create mount point
mkdir -p $MOUNT_DIR
mount $VOLUME_PATH $MOUNT_DIR
# Add to /etc/fstab for automatic mounting
echo "$VOLUME_PATH $MOUNT_DIR ext4 defaults,nofail 0 2" >> /etc/fstab

# # Add Docker's official GPG key:
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install -y git docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker
systemctl enable docker
