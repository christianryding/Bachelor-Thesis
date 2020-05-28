#! /bin/bash

# Set number of connections and port for server 
nrJails=$1
port=$2

jexec jail_server iperf -s -p $port -P $nrJails >> /home/christian/Desktop/iperf"$nrJails".txt
