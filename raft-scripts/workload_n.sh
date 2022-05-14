#!/bin/bash

if [ "$#" -ne 3 ]
then
  echo "Require 3 arguments (number of threads, number of nodes, number of queries), $# provided"
  exit 1
fi
N_THREADS=$1
NUM_NODES=$2
NUM_QUERIES=$3

for ((i = 0; i < ${N_THREADS}; i++)) do
  multitime -q -n ${NUM_QUERIES} -s 0 bash single_write_n.sh ${NUM_NODES} &
  pids[${i}]=$!
  # echo "Workload thread #${i} started (pid: ${pids[${i}]})"
done

echo "Waiting for workload completion..."
for pid in ${pids[*]}; do
    wait $pid
    # echo "Workload thread (pid: $pid) completed"
done
