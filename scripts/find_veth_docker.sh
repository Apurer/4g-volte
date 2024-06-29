#!/bin/bash

check_retval() {
  if [ $1 -ne 0 ]; then
    echo "An error occurred."
    exit $1
  fi
}

function show_help {
  echo "This script finds out which vethXXXX is connected to what container!"
  echo "Example: sudo ./find_veth_docker.sh"
  exit
}

NAME=""
INTF=""

while getopts "h?n:i:" opt; do
  case "$opt" in
    h|\?)
      show_help
      ;;
    n)
      NAME=$OPTARG
      ;;
    i)
      INTF=$OPTARG
      ;;
    *)
      show_help
      ;;
  esac
done

echo "Testing dependencies (jq)..."
which jq >> /dev/null
retval=$(echo $?)
check_retval $retval

if [ -z $NAME ]; then
  cmd="docker ps --format {{.Names}}"
  cmd_test=$($cmd)
  if [[ -z $cmd_test ]]; then
    echo "There is no container running on the system..."
    exit
  fi
else
  cmd="docker ps --format {{.Names}} -f name=$NAME"
  cmd_test=$($cmd)
  if [[ -z $cmd_test ]]; then
    echo "There is no container running on the system with the name ${NAME}.."
    exit
  fi
fi
if [ -z $INTF ]; then
  INTF="eth0"
fi

echo "VETH@HOST       VETH_MAC        	CONTAINER_IP    CONTAINER_MAC           Bridge@HOST             Bridge_IP       Bridge_MAC              CONTAINER"

for i in $($cmd); do
  PID=$(docker inspect $i --format "{{.State.Pid}}")
  if [ -z $PID ]; then
    echo "Could not find PID for container $i"
    continue
  fi

  PID=$(docker inspect $i --format "{{.State.Pid}}")
  INDEX=$(sudo cat /proc/$PID/net/igmp |grep "$INTF"| awk '{print $1}') 
  veth=$(sudo ip -br addr |grep "if${INDEX} "|awk '{print $1}'|cut -d '@' -f 1) 
  if [[ -z $veth ]]
  then
    veth="N/A\t" 
    veth_mac="N/A\t\t" 
  else
    veth_mac=$(sudo ip a|grep $veth -A 2|grep ether|awk '{print $2}')
  fi
  network_mode=$(docker inspect $i|jq -r .[].HostConfig.NetworkMode)
  if [ "$network_mode" == "default" ]
  then
    network="bridge"
  else
    network=$network_mode
  fi
    
  ip_address=$(docker inspect $i|jq -r .[].NetworkSettings.Networks.$network.IPAddress)
  mac_address=$(docker inspect $i| jq -r .[].NetworkSettings.Networks.$network.MacAddress)
  gateway=$(docker inspect $i| jq -r .[].NetworkSettings.Networks.$network.Gateway)
  if [[ -z $gateway ]]
  then
    bridge="N/A\t"
    bridge_ip="N/A\t"
    bridge_mac="N/A\t\t"
  else
    bridge=$(sudo ip -br addr |grep $gateway|awk '{print $1}')
    if [[ -z $bridge ]]
    then
      bridge="N/A\t"
      bridge_ip="N/A"
      bridge_mac="N/A"
    else
      bridge_ip=$(sudo ip a |grep $bridge |grep inet|awk '{print $2}')
      bridge_mac=$(ip a |grep ": ${bridge}:" -A 1| grep ether| awk '{print $2}')
    fi
  fi
  if [ "$bridge" == "docker0" ]
  then
    echo -e "${veth}\t${veth_mac}\t${ip_address}\t${mac_address}\t${bridge}\t\t\t${bridge_ip}\t${bridge_mac}\t${i}"
  else
    echo -e "${veth}\t${veth_mac}\t${ip_address}\t${mac_address}\t${bridge}\t\t${bridge_ip}\t${bridge_mac}\t${i}"
  fi
done
echo -e "\n\nIf you see N/A for veth, try using different interface identifier, e.g., eth1"
