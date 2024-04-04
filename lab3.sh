#!/bin/bash

VERBOSE=""
[ "$1" = "-verbose" ] && VERBOSE="-verbose"

execute_remote_config() {
    host="$1"
    name="$2"
    ip="$3"
    other_name="$4"
    other_ip="$5"
    
    scp "configure-host_v3.sh" "remoteadmin@${host}-mgmt:/root"
    ssh "remoteadmin@${host}-mgmt" -- "/root/configure-host_v3.sh $VERBOSE -host $name -ip $ip -hostfile $other_name $other_ip"
}

execute_remote_config "server1" "loghost" "192.168.16.3" "webhost" "192.168.16.4"
execute_remote_config "server2" "webhost" "192.168.16.4" "loghost" "192.168.16.3"

./configure-host_v3.sh $VERBOSE -hostfile "loghost" "192.168.16.3"
./configure-host_v3.sh $VERBOSE -hostfile "webhost" "192.168.16.4"
