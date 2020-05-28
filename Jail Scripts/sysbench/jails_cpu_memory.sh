#!/bin/bash


# Set test case
type=$1

# Set nr of containers
nrCont=$2

# testRuns
testRuns=10


if [ "$type" == "cpu" ] || [ "$type" == "memory" ] ; then
    echo "Starting sysbench testrun $testRunNr with $nrCont containers"
else
    echo "bad type argument"
    exit 1
fi

# CPU test
if [ "$type" == "cpu" ] ; then
    # Loop all 10 test times
    for ((z = 1; z <= $testRuns; z++))
    do
	echo "Running CPU test $z"
	# Running all containers
	for ((i = 1; i <= nrCont; i++))
	do
	    jexec jail"$i" sysbench $type --time=10 --cpu-max-prime=10000 --threads=8 run >> ./tests/cpu/cont_"$i" &
	done
	sleep 15
	echo "Finished running CPU test $z"
    done

# Memory test 
else
    # Loop all 10 test times
    for ((z = 1; z <= $testRuns; z++))
    do
	echo "Running MEMORY test $z"
	# Running all containers
	for ((i = 1; i <= nrCont; i++))
	do
	    jexec jail"$i" sysbench $type --time=10 --threads=8 run >> ./tests/memory/cont_"$i" & 
    	done
	sleep 15
	echo "Finished running MEMORY test $z"
    done
fi


