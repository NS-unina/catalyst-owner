#!/bin/bash
source functions.sh

delete_bridge "br0"
delete_interface "tap0" "tap1" "tap2" "tap3" "tap4"
