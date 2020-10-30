#!/bin/bash

# Flush all chains
iptables -F
iptables -t nat -F

# Delete  the  optional  user-defined  chain specified
iptables -X
iptables -t nat -X

# Zero the packet and byte counters in all chains
iptables -Z
iptables -t nat -Z

# default policies to accept
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
