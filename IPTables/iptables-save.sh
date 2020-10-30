#!/bin/bash

#
# Debian/Ubuntu
#
# Since Ubuntu 10.04 LTS (Lucid) and Debian 6.0 (Squeeze) there is a package with the name "iptables-persistent" which
# takes over the automatic loading of the saved iptables rules. To do this, the rules must be saved in the file
# /etc/iptables/rules.v4 for IPv4 and /etc/iptables/rules.v6 for IPv6.
# apt-get install iptables-persistent

iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

# manual restore
# iptables-restore < /etc/iptables/rules.v4
# ip6tables-restore < /etc/iptables/rules.v6

#
# RHEL/CentOS
#
# RHEL/CentOS also offer simple methods to permanently save iptables rules for IPv4 and IPv6.
# There is a service called "iptables". This must be enabled.
# chkconfig --list | grep iptables
# iptables       	0:off	1:off	2:on	3:on	4:on	5:on	6:off
# chkconfig iptables on
# The rules are saved in the file /etc/sysconfig/iptables for IPv4 and in the file /etc/sysconfig/ip6tables for IPv6.
# You may also use the init script in order to save the current rules.
# service iptables save

# iptables-save > /etc/sysconfig/iptables
# ip6tables-save > /etc/sysconfig/ip6tables

# manual restore
# iptables-restore < /etc/sysconfig/iptables
# ip6tables-restore < /etc/sysconfig/ip6tables