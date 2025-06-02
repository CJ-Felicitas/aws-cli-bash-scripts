#!/bin/bash

# conf
MOUNT_DIR="/home/ubuntu/mnt"
BUCKET_NAME="poc-s3mount-bucket"
MOUNT_OPTIONS="-o iam_role=auto -o endpoint=ap-southeast-1 -o allow_other -o umask=022 -o dbglevel=warn"


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to display menu
show_menu() {
    clear
    echo -e "${YELLOW}==================================${NC}"
    echo -e "${YELLOW}       S3FS Mount Manager          ${NC}"
    echo -e "${YELLOW}==================================${NC}"
    echo -e "1. ${GREEN}Mount S3 Bucket${NC}"
    echo -e "2. ${RED}Unmount S3 Bucket${NC}"
    echo -e "3. Check Mount Status"
    echo -e "4. Exit"
    echo -e "5. List Files in Mounted Directory"
    echo -e "${YELLOW}==================================${NC}"
}

# Function to mount S3 bucket
mount_s3fs() {
    echo -e "${YELLOW}[INFO] Attempting to mount $BUCKET_NAME to $MOUNT_DIR...${NC}"
    
    if mount | grep -q "s3fs on $MOUNT_DIR"; then
        echo -e "${RED}[WARN] S3FS is already mounted at $MOUNT_DIR.${NC}"
        return 1
    fi

    mkdir -p "$MOUNT_DIR" || {
        echo -e "${RED}[ERROR] Failed to create $MOUNT_DIR.${NC}" >&2
        return 1
    }

    if s3fs "$BUCKET_NAME" "$MOUNT_DIR" $MOUNT_OPTIONS; then
        echo -e "${GREEN}[SUCCESS] S3FS mounted successfully at $MOUNT_DIR.${NC}"
        return 0
    else
        echo -e "${RED}[ERROR] Failed to mount S3FS.${NC}" >&2
        return 1
    fi
}

# Function to unmount S3 bucket
unmount_s3fs() {
    echo -e "${YELLOW}[INFO] Checking mount status...${NC}"
    
    if ! mount | grep -q "s3fs on $MOUNT_DIR"; then
        echo -e "${RED}[WARN] No S3FS mount found at $MOUNT_DIR.${NC}"
        return 1
    fi

    echo -e "${YELLOW}[INFO] Attempting to unmount $MOUNT_DIR...${NC}"
    if fusermount -u "$MOUNT_DIR"; then
        echo -e "${GREEN}[SUCCESS] Unmounted S3FS from $MOUNT_DIR.${NC}"
        return 0
    else
        echo -e "${YELLOW}[WARN] Trying force unmount...${NC}"
        if fusermount -uz "$MOUNT_DIR"; then
            echo -e "${GREEN}[SUCCESS] Force unmount succeeded.${NC}"
            return 0
        else
            echo -e "${RED}[ERROR] Force unmount failed! Manual intervention required.${NC}" >&2
            return 1
        fi
    fi
}

# Function to check mount status
check_mount() {
    echo -e "${YELLOW}[INFO] Checking mount status...${NC}"
    
    if mount | grep -q "s3fs on $MOUNT_DIR"; then
        MOUNT_INFO=$(findmnt -n -o SOURCE,TARGET,FSTYPE,OPTIONS "$MOUNT_DIR" 2>/dev/null)
        echo -e "${GREEN}[MOUNTED] S3FS is active:${NC}"
        echo -e "Bucket: ${BUCKET_NAME}"
        echo -e "Mount Point: ${MOUNT_DIR}"
        echo -e "Details:"
        echo "$MOUNT_INFO" | column -t
        return 0
    else
        echo -e "${RED}[NOT MOUNTED] No active S3FS mount at $MOUNT_DIR.${NC}"
        if [ -d "$MOUNT_DIR" ]; then
            echo -e "Directory exists: $(ls -ld $MOUNT_DIR)"
        fi
        return 1
    fi
}

# New function to list files in mounted directory
list_files() {
    echo -e "${YELLOW}[INFO] Listing files in $MOUNT_DIR...${NC}"

    if mount | grep -q "s3fs on $MOUNT_DIR"; then
        ls -lah "$MOUNT_DIR"
        return 0
    else
        echo -e "${RED}[ERROR] S3FS is not mounted at $MOUNT_DIR. Cannot list files.${NC}"
        return 1
    fi
}

# Main menu loop
while true; do
    show_menu
    read -p "Choose an option (1-5): " choice

    case $choice in
        1)
            mount_s3fs
            ;;
        2)
            unmount_s3fs
            ;;
        3)
            check_mount
            ;;
        4)
            echo -e "${YELLOW}Exiting...${NC}"
            exit 0
            ;;
        5)
            list_files
            ;;
        *)
            echo -e "${RED}Invalid option! Please choose 1-5.${NC}"
            ;;
    esac

    read -p "Press [Enter] to continue..."
done
