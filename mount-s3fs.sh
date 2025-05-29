#!/bin/bash
set -e

BUCKET_NAME="poc-s3-mount-test"
MOUNT_DIR="/mnt/s3bucket"
S3FS_LOG="/var/log/s3fs.log"

# Check if already mounted
if mountpoint -q "$MOUNT_DIR"; then
    echo "$MOUNT_DIR is already mounted. Exiting."
    exit 0
fi

# Create mount directory if it doesn't exist
sudo mkdir -p "$MOUNT_DIR"

echo "Mounting S3 bucket $BUCKET_NAME to $MOUNT_DIR"
sudo s3fs "$BUCKET_NAME" "$MOUNT_DIR" \
    -o iam_role=auto \
    -o allow_other \
    -o use_path_request_style \
    -o url=https://s3.amazonaws.com \
    -o umask=0022 \
    -o mp_umask=0022 \
    -o multireq_max=5 \
    -o curldbg \
    -o logfile="$S3FS_LOG"

echo "Mount completed. Verifying contents of $MOUNT_DIR:"
ls -la "$MOUNT_DIR"
