#!/bin/bash

# DESC:         Creates an OVS bridge and assigns it a specified MAC address. 
#               If the bridge already exists, the operation is aborted.
# GLOBALS:      None  
# ARGS:    
#               - bridge_name: Name of the OVS bridge to be created.  
#               - bridge_hwaddr: MAC address to assign to the bridge.  
# OUTPUTS:      
#               - 0: Operation completed successfully.  
#               - 1: Operation failed.  
# RETURNS:      None  
# USAGE:        create_ovs_bridge "br0" "3a:4d:a7:05:2a:45"  
create_ovs_bridge() {
  local bridge_name=$1
  local bridge_hwaddr=$2

  ovs-vsctl add-br $bridge_name
  ovs-vsctl set bridge $bridge_name other_config:hwaddr=$bridge_hwaddr
}


# DESCRIPTION:  Deletes the specified OVS bridges if they exist.
# GLOBALS:      None
# ARGUMENTS:    bridge_names: List of OVS bridge names to be deleted.
# OUTPUTS:      
#               - 0: Operation completed successfully.
#               - 1: Operation failed.
# RETURNS:      None
# USAGE:        delete_bridge "br0" "br1"
delete_bridge() {
  local bridges=("$@")
    
  for bridge_name in "${bridges[@]}"; do
    if ovs-vsctl show | grep -q "Bridge $bridge_name"; then
      ovs-vsctl del-br $bridge_name
    fi
  done
}


# DESC:        Creates a TAP interface and associates it with an Open vSwitch (OvS) bridge.
#              The TAP interface is set up and added to the specified OvS bridge with a VLAN tag and OpenFlow port.
# GLOBALS:     None  
# ARGS:  
#              - tap_name: Name of the TAP interface to create  
#              - bridge_name: Name of the Open vSwitch bridge to attach the TAP interface to  
#              - tag: VLAN tag to assign to the TAP interface (optional)  
#              - ofport: OpenFlow port number to assign to the TAP interface (optional)  
# OUTPUTS:     
#              - 0: Operation completed successfully.
#              - 1: Operation failed.  
# RETURNS:     None  
# USAGE:       create_ovs_bridge "tap0" "br0" "100" "5"  
create_tap() {
  local tap_name=$1
  local bridge_name=$2
  local tag=$3
  local ofport=$4

  sudo ip tuntap add name $tap_name mode tap
  sudo ip link set $tap_name up
  sudo ovs-vsctl add-port $bridge_name $tap_name tag=$tag -- set interface $tap_name ofport=$ofport   
}

# DESC:        Deletes one or more network interfaces if they exist.
#              The function checks if each specified interface is present 
#              before attempting deletion.
# GLOBALS:     None
# ARGS:  
#              - interfaces: List of network interface names to be deleted.
# OUTPUTS:     
#               - 0: Operation completed successfully.
#               - 1: Operation failed.
# RETURNS:     None
# USAGE:       delete_interface "tap0" "tap2"
delete_interface() {
    local interfaces=("$@")

    for interface_name in "${interfaces[@]}"; do
        if ip a | grep -q "$interface_name:"; then
            ip link delete $interface_name
        fi
    done
}

# DESC:         Moves a TAP interface into the network namespace of a 
#               specified Docker container.
# GLOBALS:      None
# ARGS:  
#               - container_name: Docker container name
# OUTPUTS:     
#               - 0: Operation completed successfully.
#               - 1: Operation failed.
# RETURNS:     None
# USAGE:       attach_container "my_container"
attach_container() {
    local container_name=$1 

    local PID=$(docker inspect -f '{{.State.Pid}}' "$container_name")
    ip link set tap0 netns "$PID"
}