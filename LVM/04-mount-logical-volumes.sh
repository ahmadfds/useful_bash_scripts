#!/bin/bash

# Mounting Logical Volumes on Boot and on Demand
# To better identify a logical volume we will need to find out what its UUID (a non-changing attribute that uniquely identifies a formatted storage device) is.
# To do that, use blkid followed by the path to each device:
blkid /dev/vg00/vol_projects
blkid /dev/vg00/vol_backups

# Create mount points for each LV:
mkdir /home/projects
mkdir /home/backups

# To insert the corresponding entries in /etc/fstab (make sure to use the UUIDs obtained before):
UUID=b85df913-580f-461c-844f-546d8cde4646 /home/projects	ext4 defaults 0 0
UUID=e1929239-5087-44b1-9396-53e09db6eb9e /home/backups ext4	defaults 0 0

# Then save the changes and mount the LVs:
mount -a

# To find the mounted volumes
mount | grep home
