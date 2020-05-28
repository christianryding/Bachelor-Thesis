#!/usr/bin/env bash

# Set test case
nrCont=$1

docker pull maokeibox/time:latest

countExitedContainers () {
	return $(docker ps -a | grep "maokeibox/time" | grep "Exited" | wc -l)
}

#echo "First run creation run time:" >> ./timeToRun"$nrCont".txt
#date +%s.%N >> ./timeToRun"$nrCont".txt
#echo "Docker times:" >> ./timeToRun"$nrCont".txt
# start Docker containers
for ((i = 1; i <= nrCont; i++))
do
    docker run -d --name timer$i maokeibox/time &
done
#wait for all to exit
exited="0"
while [ $nrCont -gt $exited ]; do
	sleep 2;
	countExitedContainers
	exited=$?
done
echo "Docker start time:" >> ./timeToRunInspect"$nrCont".txt

for ((i = 1; i <= nrCont; i++))
do
    docker start timer$i &
done
#wait for all to exit
sleep 4
exited="0"
while [ $nrCont -gt $exited ]; do
	sleep 2;
	countExitedContainers
	exited=$?
done
#Collect second results
for ((i = 1; i <= nrCont; i++))
do
	START=$(docker inspect --format='{{.State.StartedAt}}' timer$i | xargs date +%s.%N -d)
	FINISHED=$(docker inspect --format='{{.State.FinishedAt}}' timer$i | xargs date +%s.%N -d)
	echo "S:$START F:$FINISHED" 
	DIFF=$(echo "$FINISHED - $START" | bc -l) 
	echo $DIFF >> ./timeToRunInspect"$nrCont".txt
done
#Cleanup
docker rm $(docker ps -a -q)
exit
