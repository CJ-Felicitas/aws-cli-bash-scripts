#!/bin/bash
set -e

MOUNT_DIR="/mnt/s3bucket"

if mountpoint -q "$MOUNT_DIR"; then
    echo "Unmounting $MOUNT_DIR..."
    sudo umount "$MOUNT_DIR"
    echo "Unmount completed."
else
    echo "$MOUNT_DIR is not mounted."
fi
