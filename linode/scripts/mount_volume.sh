#!/bin/bash

# Exit with non zero when fail
set -e

VOLUME_PATH="$1"
MOUNT_DIR="$2"

if [ -z "$VOLUME_PATH" ] || [ -z "$MOUNT_DIR" ]; then
  echo "Usage: $0 <VOLUME_PATH> <MOUNT_DIR>"
  exit 1
fi

# Check if the device is already mounted
if mountpoint -q "$MOUNT_DIR"; then
  echo "$MOUNT_DIR is already mounted."
else
  # Format volume if needed
  FS=$(blkid -o value -s TYPE "$VOLUME_PATH" || true)

  if [ -z "$FS" ]; then
    echo "No filesystem detected on $VOLUME_PATH. Formatting..."
    mkfs.ext4 "$VOLUME_PATH"
  else
    echo "Filesystem detected on $VOLUME_PATH. No formatting needed."
  fi

  # Create mount point
  mkdir -p "$MOUNT_DIR"

  # Mount the volume
  mount "$VOLUME_PATH" "$MOUNT_DIR"

  # Add to /etc/fstab for automatic mounting
  echo "$VOLUME_PATH $MOUNT_DIR ext4 defaults,nofail 0 2" >> /etc/fstab
  echo "Mounted $VOLUME_PATH to $MOUNT_DIR and added to /etc/fstab."
fi
