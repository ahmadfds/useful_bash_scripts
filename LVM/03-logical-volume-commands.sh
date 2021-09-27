#!/bin/bash

# To create logical volume
# For example, let’s create two LVs named vol_projects (10 GB) and vol_backups (remaining space),
# which we can use later to store project documentation and system backups, respectively.
#
# The -n option is used to indicate a name for the LV, whereas -L sets a fixed size and -l (lowercase L) is
# used to indicate a percentage of the remaining space in the container VG.
lvcreate -n vol_projects -L 10G vg00
lvcreate -n vol_backups -l 100%FREE vg00

#You can view the list of LVs and basic information with:
lvs

# To view detailed information
lvdisplay

# To view information about a single LV, use lvdisplay with the VG and LV as parameters, as follows:
lvdisplay vg00/vol_projects


# Before each logical volume can be used, we need to create a filesystem on top of it.
# We’ll use ext4 as an example here since it allows us both to increase and reduce the size
# of each LV (as opposed to xfs that only allows to increase the size):
mkfs.ext4 /dev/vg00/vol_projects
mkfs.ext4 /dev/vg00/vol_backups


# Due to the nature of LVM, we can easily reduce the size of the latter (say 2.5 GB)
# and allocate it for the former, while resizing each filesystem at the same time.
# Fortunately, this is as easy as doing:
lvreduce -L -2.5G -r /dev/vg00/vol_projects
lvextend -l +100%FREE -r /dev/vg00/vol_backups
# ====================================================================================================
# IMPORTANT: It is important to include the minus (-) or plus (+) signs while resizing a logical volume.
# Otherwise, you’re setting a fixed size for the LV instead of resizing it.
# ====================================================================================================


# To remove the created volumes
lvremove /dev/vg00/vol_projects