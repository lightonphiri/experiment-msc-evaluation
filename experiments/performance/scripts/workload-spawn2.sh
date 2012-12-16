#!/bin/sh
for workloads in `seq 1 15`
do
echo $workloads
w2=w$workloads
echo $w2
echo Processing directory.... /home/lphiri/datasets/ndltd/workload/w$workloads/chunked
echo Copying contents to... /home/lphiri/datasets/ndltd/workload2/w$workloads
python -c "import simplyctperformance; simplyctperformance.spawnstructworkload('/home/lphiri/datasets/ndltd/workload/w$workloads/chunked', '/home/lphiri/datasets/ndltd/workload2', '$w2')";
done
