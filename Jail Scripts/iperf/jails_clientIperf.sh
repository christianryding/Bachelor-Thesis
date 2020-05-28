#! /bin/bash

# Set number of clients and port to connect to
nrJails=$1
port=$2

# start jails
for ((i = 1; i <= nrJails; i++))
do
    jexec jail"$i" iperf -p $port -c 192.168.0.05 &
done
