#! /bin/bash

# Set test case
nrCont=$1

# start io tests
for ((i = 1; i <= nrCont; i++))
do
    mv /usr/jails/jail"$i"/tmp/result/* test/result"$i"
done

exit
