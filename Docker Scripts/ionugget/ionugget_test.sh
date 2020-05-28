#!/usr/bin/env bash

num=10

removeAllContainers () {
	echo "Removing all containers!"
	docker rm $(docker ps -a -q)
}

countExitedContainers () {
	return $(docker ps -a | grep "maokeibox/ionugget" | grep "Exited" | wc -l)
}

countUpContainers () {
	return $(docker ps -a | grep "maokeibox/ionugget" | grep "Up" | wc -l)
}

docker pull maokeibox/ionugget:latest

for (( i=1; i <= num; i++ ))
do
	docker run -d --name ionugget$i maokeibox/ionugget &
done

exited="0"
while [ $num -gt $exited ]; do
	sleep 2;
	countExitedContainers
	exited=$?
done
echo "All containers exited $exited"
for (( i=1; i <= num; i++ ))
do
	docker logs ionugget$i | sed -n '10,15p' >> ~/ionugget_result.txt
	echo "" >> 	~/ionugget_result.txt
done
removeAllContainers
