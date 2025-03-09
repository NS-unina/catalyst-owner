#!/bin/bash
source functions.sh

create_ovs_bridge "br0" "3a:4d:a7:05:2a:48" 

create_veth "veth0" "br0"
create_veth "veth1" "br0"
create_veth "veth2" "br0"
create_veth "veth3" "br0"
create_veth "veth4" "br0"

attach_container "postgres" "veth0"
attach_container "content-server" "veth1"
attach_container "lambdas" "veth2"
attach_container "lamb2" "veth3"
attach_container "nginx" "veth4"

assign_ip_container "postgres" "veth0" "192.168.100.15/24"
assign_ip_container "content-server" "veth1" "192.168.100.14/24"
assign_ip_container "lambdas" "veth2" "192.168.100.13/24"
assign_ip_container "lamb2" "veth3" "192.168.100.12/24"
assign_ip_container "nginx" "veth4" "192.168.100.11/24"

