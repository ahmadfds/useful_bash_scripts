#!/bin/bash

## Create a file that will be used for swap:
# sudo dd if=/dev/zero of=/swapfile bs=1024 count=1048576


## Only the root user should be able to write and read the swap file.
# sudo chmod 600 /swapfile


## Use the mkswap utility to set up the file as Linux swap area:
# sudo mkswap /swapfile


## Enable the swap with the following command:
# sudo swapon /swapfile


## To make the change permanent open the /etc/fstab file and append the following line:
# /swapfile swap swap defaults 0 0


## To verify that the swap is active, use either the swapon or the free command as shown below:
# sudo swapon --show
# sudo free -h


## Swappiness is a Linux kernel property that defines how often the system will use the swap space.
## Swappiness can have a value between 0 and 100. A low value will make the kernel to try to avoid swapping whenever possible,
## while a higher value will make the kernel to use the swap space more aggressively.
## The default swappiness value is 60. You can check the current swappiness value by typing the following command:
# cat /proc/sys/vm/swappiness
## While the swappiness value of 60 is OK for most Linux systems, for production servers, you may need to set a lower value.
## For example, to set the swappiness value to 10, you would run the following sysctl command:
# sudo sysctl vm.swappiness=10
## To make this parameter persistent across reboots append the following line to the /etc/sysctl.conf file:
# vm.swappiness=10
## The optimal swappiness value depends on your system workload and how the memory is being used.
# You should adjust this parameter in small increments to find an optimal value.



## If for any reason you want to DEACTIVATE and REMOVE the swap file, follow these steps:
## First, deactivate the swap by typing:
# sudo swapoff -v /swapfile

## Remove the swap file entry /swapfile swap swap defaults 0 0 from the /etc/fstab file.
## Finally, delete the actual swapfile file using the rm command:
# sudo rm /swapfile
