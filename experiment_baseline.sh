#/!bin/bash

int_handler() {
    echo "Interrupted."
    kill $PPID
    bash stop-cluster.sh
    exit 1
}
trap 'int_handler' INT


for ((i = 1; i < 24; i++)) do
  N_THREADS=${i}
  echo ">>> N_THREADS= ${N_THREADS}"

  # start new raft cluster
  bash start-cluster.sh

  # run benchmark
  docker run --rm --name rclient --net raftnet --ip 172.18.1.10 raft-client bash workload.sh ${N_THREADS}

  # stop the cluster
  bash stop-cluster.sh

  echo "<<< N_THREADS= ${N_THREADS}"
done