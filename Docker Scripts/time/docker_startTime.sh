#!/usr/bin/env bash

# Set test case
nrCont=$1

docker pull maokeibox/time:latest

#START=$(docker inspect --format='{{.State.StartedAt}}' test)
#STOP=$(docker inspect --format='{{.State.FinishedAt}}' test)

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
#Collect first results
#for ((i = 1; i <= nrCont; i++))
#do
#    docker logs timer$i >> ./timeToRun"$nrCont".txt
#done
#Second run
echo "Docker start time:" >> ./timeToRun"$nrCont".txt
date +%s.%N >> ./timeToRun"$nrCont".txt
echo "Docker times:" >> ./timeToRun"$nrCont".txt

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
    docker logs timer$i | sed '2,2p' -n  >> ./timeToRun"$nrCont".txt
done
#Cleanup
docker rm $(docker ps -a -q)
exit
