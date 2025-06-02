#!/bin/bash
set -e

# Check if s3fs is already installed
if command -v s3fs &> /dev/null; then
    echo "s3fs is already installed."
    exit 0
fi

echo "Installing s3fs..."
sudo apt update
sudo apt install -y s3fs


if ! command -v s3fs &> /dev/null; then
    echo "ERROR: s3fs installation failed."
    exit 1
fi

FUSE_CONF="/etc/fuse.conf"
if ! grep -q "^user_allow_other" "$FUSE_CONF"; then
    echo "user_allow_other" | sudo tee -a "$FUSE_CONF"
fi

echo "s3fs installation and configuration completed"
