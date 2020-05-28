#!/usr/bin/env bash

num=10

removeAllContainers () {
	echo "Removing all containers!"
	docker rm $(docker ps -a -q)
}

countExitedContainers () {
	return $(docker ps -a | grep "maokeibox/iperfc" | grep "Exited" | wc -l)
}

countUpContainers () {
	return $(docker ps -a | grep "maokeibox/iperfc" | grep "Up" | wc -l)
}

#Server on default port 5001
#iperf -s -P 5001
read -n 1 -s -r -p "Please start iperf server on 5001"
#Docker pull image
docker pull maokeibox/iperfc:latest
#Docker network named
docker network create -d bridge --subnet 192.168.0.0/24 --gateway 192.168.0.1 dockernet
#Start iperf clients
for (( i=1; i <= num; i++ ))
do
  docker run -d --name dperfc$i maokeibox/iperfc 192.168.0.1 &
done

#remove all containers
exited="0"
while [ $num -gt $exited ]; do
  #echo "exited $exited $num"
	sleep 2;
	countExitedContainers
	exited=$?
done
echo "All containers exited $exited"
removeAllContainers
