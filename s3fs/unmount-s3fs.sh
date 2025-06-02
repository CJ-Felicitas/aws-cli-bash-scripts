#!/bin/bash

MOUNT_DIR="/home/ubuntu/mnt"

# Check if s3fs is mounted at the target directory
if mount | grep -q "s3fs on $MOUNT_DIR"; then
    echo "[INFO] Found S3FS mount at $MOUNT_DIR. Attempting to unmount..."
    
    # Try to unmount
    if fusermount -u "$MOUNT_DIR"; then
        echo "[SUCCESS] Successfully unmounted S3FS from $MOUNT_DIR"
        exit 0
    else
        echo "[ERROR] Failed to unmount $MOUNT_DIR" >&2
        echo "[INFO] Trying force unmount..."
        
        # Try force unmount if regular fails
        if fusermount -uz "$MOUNT_DIR"; then
            echo "[SUCCESS] Force unmount succeeded"
            exit 0
        else
            echo "[CRITICAL] Force unmount failed. Please check manually." >&2
            exit 1
        fi
    fi
else
    echo "[INFO] No S3FS mount found at $MOUNT_DIR. Nothing to unmount."
    exit 0
fi
