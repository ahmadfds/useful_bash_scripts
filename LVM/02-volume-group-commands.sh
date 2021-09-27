#!/bin/bash

# To create a volume group named vg00 using /dev/sdb and /dev/sdc
vgcreate vg00 /dev/sdb /dev/sdc

# To list all created volume groups
vgs

# As it was the case with physical volumes, you can also view information about this volume group by issuing:
vgdisplay vg00   #Since vg00 is formed with two 8 GB disks, it will appear as a single 16 GB drive:

# To add another physical volume to an exist volume group do the following:
vgextend vg00 /dev/sdd
