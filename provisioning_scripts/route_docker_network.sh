#!/bin/bash
BRIDGE_NETWORK=10.10.0.0
BRIDGE_MASK=255.255.0.0

# For replayability, try to remove the route
route del -net $BRIDGE_NETWORK netmask $BRIDGE_MASK dev tep0
route add -net $BRIDGE_NETWORK netmask $BRIDGE_MASK dev tep0
