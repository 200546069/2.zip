#!/bin/bash
# configure-host_v3.sh

ignore_signal() {
    trap '' SIGTERM SIGINT SIGHUP
}

ignore_signal

VERBOSE=0
HOSTNAME_UPDATED=0
IP_ADDRESS_UPDATED=0

change_hostname() {
    desired_hostname="$1"
    if [[ "$(hostname)" != "$desired_hostname" ]]; then
        echo "$desired_hostname" > /etc/hostname
        hostnamectl set-hostname "$desired_hostname"
        HOSTNAME_UPDATED=1
        logger "Hostname changed to $desired_hostname"
    fi
    [[ $VERBOSE -eq 1 && $HOSTNAME_UPDATED -eq 1 ]] && echo "Hostname changed to $desired_hostname" || echo "Hostname remains the same."
}

configure_ip() {
    desired_ip="$1"
    default_interface=$(ip route | grep default | awk '{print $5}' | head -n 1)
    if [[ ! -z "$default_interface" && ! $(ip addr show $default_interface | grep "$desired_ip") ]]; then
        sudo ip addr add "$desired_ip/24" dev "$default_interface"
        IP_ADDRESS_UPDATED=1
        logger "IP address set to $desired_ip on $default_interface"
    fi
    [[ $VERBOSE -eq 1 && $IP_ADDRESS_UPDATED -eq 1 ]] && echo "IP address set to $desired_ip." || echo "No change in IP address."
}

update_etc_hosts() {
    hostname="$1"
    ip="$2"
    if ! grep -q "$ip $hostname" /etc/hosts; then
        echo "$ip $hostname" >> /etc/hosts
        logger "Updated /etc/hosts with $hostname $ip"
    fi
    [ $VERBOSE -eq 1 ] && echo "/etc/hosts updated with $hostname $ip."
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -verbose) VERBOSE=1 ;;
        -host) change_hostname "$2"; shift ;;
        -ip) configure_ip "$2"; shift ;;
        -hostfile) update_etc_hosts "$2" "$3"; shift 2 ;;
    esac
    shift
done
