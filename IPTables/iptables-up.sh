#!/bin/bash

######################################################################
# script variables
######################################################################
LOCALIF=lo
PUBLICIF=eth0            # EX: eth0
PRIVATEIF=eth1           # EX: eth1

######################################################################
# reset iptables
######################################################################
# to enable RELATED connection state
modprobe ip_conntrack_ftp

# Flush all chains
iptables -F
iptables -t nat -F

# Delete  the  optional  user-defined  chain specified
iptables -X
iptables -t nat -X

# Zero the packet and byte counters in all chains
iptables -Z
iptables -t nat -Z

######################################################################
# basic setup
######################################################################

# all local traffic
iptables -A INPUT -i $LOCALIF -j ACCEPT
iptables -A OUTPUT -o $LOCALIF -j ACCEPT

# ssh/in
iptables -A INPUT -p tcp --sport 1024: --dport ssh -j ACCEPT
iptables -A OUTPUT -p tcp --sport ssh --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

# ssh/out
iptables -A OUTPUT -p tcp --sport 1024: --dport ssh -j ACCEPT
iptables -A INPUT -p tcp --sport ssh --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

# icmp/all
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# dns/out
iptables -A OUTPUT -p udp --dport domain -j ACCEPT
iptables -A INPUT -p udp --sport domain -j ACCEPT
iptables -A OUTPUT -p tcp --sport 1024: --dport domain -j ACCEPT
iptables -A INPUT -p tcp --sport domain --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

# ntp/out
iptables -A OUTPUT -p udp --dport ntp -j ACCEPT
iptables -A INPUT -p udp --sport ntp -j ACCEPT

# http/out
iptables -A OUTPUT -p tcp --sport 1024: --dport www -j ACCEPT
iptables -A INPUT -p tcp --sport www --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

# https/out
iptables -A OUTPUT -p tcp --sport 1024: --dport https -j ACCEPT
iptables -A INPUT -p tcp --sport https --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

######################################################################
# allow all bridge interfaces traffic (docker)
######################################################################
iptables -A INPUT -i br+ -j ACCEPT
iptables -A OUTPUT -o br+ -j ACCEPT


######################################################################
# allow all private interface traffic
######################################################################
if [ ! -z $PRIVATEIF ]; then
  iptables -A INPUT -i $PRIVATEIF -j ACCEPT
  iptables -A OUTPUT -o $PRIVATEIF -j ACCEPT
fi

######################################################################
# public interface traffic
######################################################################
if [ ! -z $PUBLICIF ]; then

  echo "Applying public interface rules"

  # smtp/in
  # iptables -A INPUT -i $PUBLICIF -p tcp --sport 1024: --dport smtp -j ACCEPT
  # iptables -A OUTPUT -o $PUBLICIF -p tcp --sport smtp --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

  # smtp/out
  # iptables -A OUTPUT -o $PUBLICIF -p tcp --sport 1024: --dport smtp -j ACCEPT
  # iptables -A INPUT -i $PUBLICIF -p tcp --sport smtp --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

  # mysql/in
  # iptables -A INPUT -i $PUBLICIF -p tcp --sport 1024: --dport mysql -j ACCEPT
  # iptables -A OUTPUT -o $PUBLICIF -p tcp --sport mysql --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

  # mysql/out
  # iptables -A OUTPUT -o $PUBLICIF -p tcp --sport 1024: --dport mysql -j ACCEPT
  # iptables -A INPUT -i $PUBLICIF -p tcp --sport mysql --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

  # SECURITY: This will reject connections above 50 from one source IP to port 80.
  # iptables -A INPUT -i $PUBLICIF -p tcp --syn --dport 80 -m connlimit --connlimit-above 50 --connlimit-mask 32 -j REJECT --reject-with tcp-reset

  # http/in
  # iptables -A INPUT -i $PUBLICIF -p tcp --sport 1024: --dport www -j ACCEPT
  # iptables -A OUTPUT -o $PUBLICIF -p tcp --sport www --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

  # https/in
  # iptables -A INPUT -i $PUBLICIF -p tcp --sport 1024: --dport https -j ACCEPT
  # iptables -A OUTPUT -o $PUBLICIF -p tcp --sport https --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

  # mongodb/in
  # iptables -A INPUT -i $PUBLICIF -p tcp --sport 1024: --dport 27017 -j ACCEPT
  # iptables -A OUTPUT -o $PUBLICIF -p tcp --sport 27017 --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

  # mongodb/out
  # iptables -A OUTPUT -o $PUBLICIF -p tcp --sport 1024: --dport 27017 -j ACCEPT
  # iptables -A INPUT -i $PUBLICIF -p tcp --sport 27017 --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

  # influx/in
  # iptables -A INPUT -i $PUBLICIF -p tcp --sport 1024: --dport 8086 -j ACCEPT
  # iptables -A OUTPUT -o $PUBLICIF -p tcp --sport 8086 --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

  # influx/out
  # iptables -A OUTPUT -o $PUBLICIF -p tcp --sport 1024: --dport 8086 -j ACCEPT
  # iptables -A INPUT -i $PUBLICIF -p tcp --sport 8086 --dport 1024: -m state --state ESTABLISHED,RELATED -j ACCEPT

  # Allow all traffic from specific IP
  # iptables -A INPUT -i $PUBLICIF -s IP_ADDRESS  -j ACCEPT
  # iptables -A OUTPUT -o $PUBLICIF -d IP_ADDRESS -j ACCEPT

  # ntp/in
  # iptables -A INPUT -i $PUBLICIF -p udp --dport ntp -j ACCEPT
  # iptables -A OUTPUT -o $PUBLICIF -p udp --sport ntp -j ACCEPT

fi

######################################################################
# drop others
######################################################################

# Deny the rest
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
iptables -A FORWARD -j DROP

# default policies to drop
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
