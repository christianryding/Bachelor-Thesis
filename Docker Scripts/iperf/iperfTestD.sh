#!/usr/bin/env bash

#number of containers
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

dockerip () {
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

docker network create iperfnet
#Docker pull image
docker pull maokeibox/iperfs:latest
docker pull maokeibox/iperfc:latest
#server
docker run -d --name iperfs1 --network=iperfnet maokeibox/iperfs &
sleep 2; 
ip=$(dockerip iperfs1)
echo "IP $ip"
#Start iperf clients
for (( i=1; i <= num; i++ ))
do
  docker run -d --name dperfc$i --network=iperfnet maokeibox/iperfc $ip &
done

#remove all containers
exited="0"
while [ $num -gt $exited ]; do
  #echo "exited $exited $num"
	sleep 2;
	countExitedContainers
	exited=$?
done
docker stop iperfs1
docker logs iperfs1 > ~/iperfs.txt
echo "All containers exited $exited"
removeAllContainers
docker network rm iperfnet
