#!/bin/bash

# Configuration
MOUNT_DIR="/home/ubuntu/mnt"
MOUNT_TYPE="fuse.s3fs"

# Check if directory exists
if [ ! -d "$MOUNT_DIR" ]; then
    echo "[ERROR] Directory $MOUNT_DIR does not exist" >&2
    exit 2
fi

# Check mount status
if mount | grep -q "$MOUNT_DIR.*$MOUNT_TYPE"; then
    # Get detailed mount info
    MOUNT_INFO=$(findmnt -n -o SOURCE,TARGET,FSTYPE,OPTIONS "$MOUNT_DIR" 2>/dev/null)
    if [ -n "$MOUNT_INFO" ]; then
        echo "[MOUNTED] S3FS is properly mounted:"
        echo "$MOUNT_INFO"
        exit 0
    else
        echo "[WARNING] Appears mounted but cannot verify details" >&2
        exit 1
    fi
else
    echo "[NOT MOUNTED] No S3FS mount found at $MOUNT_DIR"
    
    # Check if directory is empty (helps diagnose issues)
    if [ -z "$(ls -A "$MOUNT_DIR" 2>/dev/null)" ]; then
        echo "[INFO] Directory $MOUNT_DIR is empty"
    else
        echo "[WARNING] Directory $MOUNT_DIR contains files (may be stale data)" >&2
    fi
    
    exit 3
fi
