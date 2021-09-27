#!/bin/bash

# to create a snapshot from a logical volume
lvcreate -L 5G -s /dev/vg00/vol_projects

# to remove the snapshot
lvremove group/snap-name