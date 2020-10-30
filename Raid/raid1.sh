#!/bin/bash

## Run the following command to check the device name.
# sudo fdisk -l


## Then run the following 2 commands to make new MBR partition table on the two hard drives.
## (Note: this is going to wipe out all existing partitions and data from these two hard drives. Make sure your data is backed up.)
## You can create GPT partition table by replacing msdos with gpt
# sudo parted /dev/(EX: sdb) mklabel msdos
# sudo parted /dev/(EX: sda) mklabel msdos


## Next, use the fdisk command to create a new partition on each drive and format them as a Linux raid autodetect file system.
## First do this on /dev/sdb, the apply the same steps on the second drive
## sudo fdisk /dev/sdb
## Follow these instructions.
## Type n to create a new partition.
## Type p to select primary partition.
## Type 1 to create /dev/sdb1.
## Press Enter to choose the default first sector
## Press Enter to choose the default last sector. This partition will span across the entire drive.
## Typing p will print information about the newly created partition. By default the partition type is Linux.
## We need to change the partition type, so type t.
## Enter fd to set partition type to Linux raid autodetect.
## Type p again to check the partition type.
## Type w to apply the above changes.


## Install mdadm, mdadm is used for managing MD (multiple devices) devices, also known as Linux software RAID.
## Debian/Ubuntu:     sudo apt install mdadm
## CentOS/Redhat:     sudo yum install mdadm
## SUSE:              sudo zypper install mdadm
## Arch Linux         sudo pacman -S mdadm


## Let’s examine the two devices.
# sudo mdadm --examine /dev/sdb /dev/sdc


## At this stage, there’s no RAID setup on /dev/sdb1 and /dev/sdc1 which can be inferred with this command.
# sudo mdadm --examine /dev/sdb1 /dev/sdc1


## Execute the following command to create RAID 1. The logical drive will be named /dev/md0.
# sudo mdadm --create /dev/md0 --level=mirror --raid-devices=2 /dev/sdb1 /dev/sdc1

## Now we can check it with:
#cat /proc/mdstat


## To get more detailed information about /dev/md0, we can use the below commands:
# sudo mdadm --detail /dev/md0


## To obtain detailed information about each raid device, run this command:
# sudo mdadm --examine /dev/sdb1 /dev/sdc1


## Let’s format it to ext4 file system.
# sudo mkfs.ext4 /dev/md0


## Then create a mount point /mnt/raid1 and mount the RAID 1 drive.
# sudo mkdir /mnt/raid1
# sudo mount /dev/md0 /mnt/raid1


## You can use this command to check how much disk space you have.
# df -h /mnt/raid1


## To check the status of our raid:
# sudo mdadm --detail /dev/md0


## To add the failed drive (in this case /dev/sdc1) back to the RAID, run the following command.
# sudo mdadm --manage /dev/md0 --add /dev/sdc1


## It’s very important to save our RAID1 configuration with the below command.
## On some Linux distribution such as CentOS, the config file for mdadm is /etc/mdadm.conf.
# sudo mdadm --detail --scan --verbose | sudo tee -a /etc/mdadm/mdadm.conf


##  You should run the following command to generate a new initramfs image after running the above command.
# sudo update-initramfs -u


## To automatically mount the RAID 1 logical drive on boot time, add an entry in /etc/fstab file like below.
# /dev/md0   /mnt/raid1   ext4   defaults   0   0


## You may want to use the x-gvfs-show option, will let you see your RAID1 in the sidebar of your file manager.
# /dev/md0  /mnt/raid1   ext4    defaults,x-gvfs-show   0   0





## If you don’t want to use the RAID anymore, run the following command to remove the RAID.
# sudo mdadm --remove /dev/md0
## Then edit the mdadm.conf file and comment out the RAID definition.
##      #  ARRAY /dev/md0 level=raid1 num-devices=2 metadata=1.2 spares=1 name=bionic:0 UUID=76c80bd0:6b1fe526:90807435:99030af9
##      #  devices=/dev/sda1,/dev/sdb1
## Also, edit /etc/fstab file and comment out the line that enables auto-mount of the RAID device.

