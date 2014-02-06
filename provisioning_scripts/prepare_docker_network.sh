#!/bin/bash
# The 'other' host
HOST_NUMBER=$1
OTHER_HOSTS=$2

# Bridge address
BRIDGE_ADDRESS=10.10.$HOST_NUMBER.1/24
UNION_IP=192.168.250.$HOST_NUMBER
UNION_ADDRESS=$UNION_IP/24

# Add the docker0 bridge
brctl addbr docker0
# Set up the IP for the docker0 bridge
ip address add $BRIDGE_ADDRESS dev docker0
# Activate the bridge
ip link set docker0 up

# Add the br0 Open vSwitch bridge
ovs-vsctl add-br br0
# Create the tunnel to the other host and attach it to the
# br0 bridge
COUNTER=0
for REMOTE_IP in $OTHER_HOSTS; do
  let COUNTER=COUNTER+1
  ovs-vsctl add-port br0 gre$COUNTER -- set interface gre$COUNTER type=gre options:remote_ip=$REMOTE_IP
done
ovs-vsctl add-port br0 tep0 -- set interface tep0 type=internal
ip address add $UNION_ADDRESS dev tep0
ip link set tep0 up

# Add the br0 bridge to docker0 bridge
brctl addif docker0 br0
