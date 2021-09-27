#!/bin/bash

# To create physical volumes on top of /dev/sdb, /dev/sdc, and /dev/sdd, do:
pvcreate /dev/sdb /dev/sdc /dev/sdd

# You can list the newly created PVs with:
pvs

# Get detailed information about each PV with:
pvdisplay /dev/sdX   # If you omit /dev/sdX as parameter, you will get information about all the PVs.

# After scaling the volume you have to resize the pv:
pvresize /dev/sdX