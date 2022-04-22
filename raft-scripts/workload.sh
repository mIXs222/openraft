#!/bin/bash

if [ "$#" -ne 1 ]
then
  echo "Require one argument (number of threads), $# provided"
  exit 1
fi
N_THREADS=$1

for ((i = 0; i < ${N_THREADS}; i++)) do
  multitime -q -n 1000 -s 0 bash single_write.sh &
  pids[${i}]=$!
  # echo "Workload thread #${i} started (pid: ${pids[${i}]})"
done

echo "Waiting for workload completion..."
for pid in ${pids[*]}; do
    wait $pid
    # echo "Workload thread (pid: $pid) completed"
done
