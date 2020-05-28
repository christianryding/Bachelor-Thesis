#!/usr/bin/env bash
echo "Arguments:"
echo "type $TYPE"
echo "type $TIME"
echo "threads $THREADS"
echo "cpu max primes $CPUMAXPRIMES"
echo ""

if [ $TYPE == "cpu" ]; then
	sysbench $TYPE --time=$TIME --threads=$THREADS --cpu-max-prime=$CPUMAXPRIMES run >> /var/result/$(hostname)
elif [ $TYPE == "memory" ]; then
	sysbench $TYPE --time=$TIME --threads=$THREADS run >> /var/result/$(hostname)
else
   echo "BAD TYPE ARGUMENT"
fi
cat /var/result/$(hostname)
