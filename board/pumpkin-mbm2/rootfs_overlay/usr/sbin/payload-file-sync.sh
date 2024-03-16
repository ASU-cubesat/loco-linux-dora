#!/bin/bash

# This script is called by the DORA scheduler service (chrontab wasn't isntalled in our version of locolinux)

max_file_count=15; # right now, this is the same for every dir

# Check if eth0 interface is up - if it's not, CM4 is probably not on
if [ "$(cat /sys/class/net/eth0/carrier)" -ne 1 ]; then
    echo "eth0 interface is not up. Exiting..."
    exit 1
fi

# Rsync directories from remote to local
rsync -avz --delete dora2@10.0.2.10:/home/dora2/data/ /home/dora/payload-data

files_deleted=false; # used to sync after if files were deleted

# Define function to remove oldest files if more than 15 files are present
check_and_remove_oldest() {
    local directory="$1"
    while [ "$(ls -1 "$directory" | wc -l)" -gt $max_file_count ]; do # while there are greater than max_file_count files in the directory
        echo "More than $max_file_count files found in $directory"
        oldest_file=$(ls -v $directory/* | head -n 1)
        echo "Removing the oldest file '$oldest_file' ..."
        rm "$oldest_file"
        files_deleted=true;
    done
}

# Call the function for each directory
check_and_remove_oldest "/home/dora/payload-data/images"
check_and_remove_oldest "/home/dora/payload-data/mode1"
check_and_remove_oldest "/home/dora/payload-data/mode2"

if [ $files_deleted = true ]; then
    rsync -avz --delete /home/dora/payload-data/ dora2@10.0.2.10:/home/dora2/data
fi
