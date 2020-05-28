#! /bin/bash

# Set test case
nrCont=$1

# start jails
for ((i = 1; i <= nrCont; i++))
do
    jexec jail"$i" ./ionugget.py -t 1 &
done

exit




