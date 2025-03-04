#!/bin/bash
source functions.sh

create_ovs_bridge "br0" "3a:4d:a7:05:2a:48" 

create_tap "tap0" "br0" "100" "5"
create_tap "tap1" "br0" "100" "5"
create_tap "tap2" "br0" "100" "5"
create_tap "tap3" "br0" "100" "5"
create_tap "tap4" "br0" "100" "5"

