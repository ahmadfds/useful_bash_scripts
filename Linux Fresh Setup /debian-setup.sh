#!/bin/bash

# I've used this package to fix the stuck processes with no clear reason, and I've recognized
# that the processes was hanged using strace -p <processID>
#
# The haveged project is an attempt to provide an easy-to-use, unpredictable random number generator
# based upon an adaptation of the HAVEGE algorithm. Haveged was created to remedy low-entropy conditions
# in the Linux random device that can occur under some workloads, especially on headless servers.
apt-get install -y haveged

# Turn off Transparent Huge Pages for redis
# The overhead THP imposes occurs only during memory allocation, because of defragmentation costs.
sysctl -w vm.nr_hugepages=0
echo never > /sys/kernel/mm/transparent_hugepage/enabled
sysctl -p