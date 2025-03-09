#!/bin/bash

# DESCRIPTION:  Creates an OVS bridge and assigns it a specified MAC address. 
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
  sudo ip link set $bridge_name up
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


# DESCRIPTION:  Creates a virtual Ethernet (veth) pair and attaches one end 
#               to an Open vSwitch (OvS) bridge. 
# GLOBALS:      None
# ARGUMENTS:
#               - veth_name: Name of the veth interface to create
#               - bridge_name: Name of the Open vSwitch bridge to attach one 
#                end of the veth pair to
# OUTPUTS:
#               - 0: Operation completed successfully.
#               - 1: Operation failed.
# RETURNS:      None
# USAGE:        create_veth "veth0" "br0"
create_veth() {
  local veth_name=$1
  local bridge_name=$2
  
  ip link add $veth_name type veth peer name $veth_name-$bridge_name
  ovs-vsctl add-port $bridge_name $veth_name-$bridge_name
  ip link set $veth_name-$bridge_name up
}


# DESCRIPTION:  Deletes one or more network interfaces if they exist.
#               The function checks if each specified interface is present 
#               before attempting deletion.
# GLOBALS:      None
# ARGS:  
#               - interfaces: List of network interface names to be deleted.
# OUTPUTS:     
#               - 0: Operation completed successfully.
#               - 1: Operation failed.
# RETURNS:      None
# USAGE:        delete_interface "tap0" "tap2"
delete_interface() {
    local interfaces=("$@")

    for interface_name in "${interfaces[@]}"; do
        if ip a | grep -q "$interface_name:"; then
            ip link delete $interface_name
        fi
    done
}


# DESCRIPTION:  Attaches a network interface to a Docker container.
# GLOBALS:      None
# ARGS:  
#               - container_name: Name of the Docker container
#               - interface_name: Name of the network interface to attach 
#                 to the container
# OUTPUTS:     
#               - 0: Operation completed successfully.
#               - 1: Operation failed.
# RETURNS:     None
# USAGE:       attach_container "my_container" "veth1" 
attach_container() {
    local container_name=$1
    local interface_name=$2

    local PID=$(docker inspect -f '{{.State.Pid}}' "$container_name")
    ip link set $interface_name netns $PID
}


# DESCRIPTION:  Assigns an IP address to a network interface inside a Docker container.
# GLOBALS:      None
# ARGS:  
#               - container_name: Name of the target Docker container
#               - interface_name: Name of the network interface inside the container
#               - cidr: IP address with subnet mask (e.g., 192.168.1.2/24)
# OUTPUTS:     
#               - 0: Operation completed successfully.
#               - 1: Operation failed.
# RETURNS:     None
# USAGE:       assign_ip_container "my_container" "veth1" "192.168.100.14/24"
assign_ip_container() {
    local container_name=$1
    local interface_name=$2
    local cidr=$3

    docker run --network=container:$container_name --cap-add=NET_ADMIN --name=configurator --rm -tid nicolaka/netshoot
    docker exec -ti configurator ip link set $interface_name up
    docker exec -ti configurator ip addr add $cidr dev $interface_name
    docker stop configurator
}


# DESCRIPTION:  <none>
# GLOBALS:      None
# ARGS:  
#               - container_name: Name of the target Docker container
#               - interface_name: Name of the network interface inside the container
#               - cidr: IP address with subnet mask (e.g., 192.168.1.2/24)
# OUTPUTS:     
#               - 0: Operation completed successfully.
#               - 1: Operation failed.
# RETURNS:     None
# USAGE:       assign_ip_container "my_container" "veth1" "192.168.100.14/24"
connect_ovs() {
    local bridge1=$1
    local bridge2=$2

    ## Add patch ports to each bridge
    #sudo ovs-vsctl add-port br0 patch0 -- set interface patch0 type=patch options:peer=patch1
    #sudo ovs-vsctl add-port br1 patch1 -- set interface patch1 type=patch options:peer=patch0
    #
    ## Bring up the interfaces
    #sudo ip link set br0 up
    #sudo ip link set br1 up

}