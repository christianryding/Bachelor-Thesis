#! /bin/bash

# Set test case
nrCont=$1

echo "Stopping containers"
# stop containers
for ((i = 1; i <= nrCont; i++))
do
    ezjail-admin stop jail"$i"
done
sleep 5

echo "Starttime:" >> ./timeToRun"$nrCont".txt
gdate +%s.%N >> ./timeToRun"$nrCont".txt



echo "Jailtimes:" >> ./timeToRun"$nrCont".txt
# start jails
for ((i = 41; i <= 72; i++))
do
    echo "$i" >> ./timeToRun"$nrCont".txt
    ezjail-admin start jail"$i" && jexec jail"$i" gdate +%s.%N >> ./timeToRun"$nrCont".txt &
done

exit




