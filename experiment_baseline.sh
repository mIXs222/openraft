#/!bin/bash

int_handler() {
    echo "Interrupted."
    kill $PPID
    bash stop-cluster.sh
    exit 1
}
trap 'int_handler' INT

# NETWORK=host
# IP_PREFIX=127.0.0.1:2100
# IP_CLIENT=127.0.0.1

NETWORK=raftnet
IP_PREFIX=172.18.0.11:2100
IP_CLIENT=172.18.0.10

for ((i = 1; i < 24; i++)) do
  N_THREADS=${i}
  echo ">>> N_THREADS= ${N_THREADS}"

  # start new raft cluster
  bash start-cluster.sh

  # run benchmark
  docker run --rm --name rclient --net ${NETWORK} --ip ${IP_CLIENT} raft-client bash workload.sh ${N_THREADS}

  # stop the cluster
  bash stop-cluster.sh

  echo "<<< N_THREADS= ${N_THREADS}"
done