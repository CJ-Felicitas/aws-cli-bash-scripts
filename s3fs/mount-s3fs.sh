#!/bin/bash

# config
MOUNT_DIR="/home/ubuntu/mnt"
BUCKET_NAME="poc-s3mount-bucket"
MOUNT_OPTIONS="-o iam_role=auto -o endpoint=ap-southeast-1 -o allow_other -o umask=022 -o dbglevel=warn"

# Function to check if S3FS is mounted
is_s3fs_mounted() {
    if mount | grep -q "s3fs on $MOUNT_DIR"; then
        return 0  # Mounted
    else
        return 1  # Not mounted
    fi
}

# Main script
if is_s3fs_mounted; then
    echo "[INFO] S3FS is already mounted at $MOUNT_DIR. Skipping mount."
    exit 0
else
    echo "[INFO] S3FS is not mounted. Attempting to mount $BUCKET_NAME to $MOUNT_DIR..."

    # check target directory if it exists
    if [ ! -d "$MOUNT_DIR" ]; then
        mkdir -p "$MOUNT_DIR" || {
            echo "[ERROR] Failed to create $MOUNT_DIR." >&2
            exit 1
        }
    fi

    # begin mount
    if s3fs "$BUCKET_NAME" "$MOUNT_DIR" $MOUNT_OPTIONS; then
        echo "[SUCCESS] S3FS mounted successfully at $MOUNT_DIR."
        exit 0
    else
        echo "[ERROR] Failed to mount S3FS." >&2
        exit 1
    fi
fi
