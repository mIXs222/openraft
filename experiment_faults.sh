#/!bin/bash

int_handler() {
    echo "Interrupted."
    kill $PPID
    bash stop-cluster.sh
    exit 1
}
trap 'int_handler' INT

if [[ $1 != "run" ]]
then
  echo "Running in mock mode, say \"run\" to execute the experiments"
fi

N_THREADS=10
echo ">>> N_THREADS= ${N_THREADS}"

# target nodes
RAFT_NODES=(
  "leader 1"
  "follower 2"
)

# clashing faults
for ((i = 0; i < ${#RAFT_NODES[@]}; i++)) do
  read -a raft_node <<< ${RAFT_NODES[$i]}
  raft_name=${raft_node[0]}
  raft_id=${raft_node[1]}

  echo ">>> Clashing [${raft_name}]"
  if [[ $1 == "run" ]]
  then
    bash start-cluster.sh
    docker container exec -d raft_${raft_id} bash fault_clashing.sh "raft-key-value --id ${raft_id} --http-addr 172.18.0.1${raft_id}:21001"
    docker run --rm --name rclient --net raftnet --ip 172.18.1.10 raft-client bash workload.sh ${N_THREADS}
    bash stop-cluster.sh
  fi
done

# slow cpu faults
CPU_PERCENTS=(
  "1"
  "2"
  "4"
  "8"
  "16"
)
for ((i = 0; i < ${#RAFT_NODES[@]}; i++)) do
  read -a raft_node <<< ${RAFT_NODES[$i]}
  raft_name=${raft_node[0]}
  raft_id=${raft_node[1]}

  for ((j = 0; j < ${#CPU_PERCENTS[@]}; j++)) do
    cpu_percent=${CPU_PERCENTS[$j]}
    echo ">>> Slow CPU ${cpu_percent}% [${raft_name}]"
    if [[ $1 == "run" ]]
    then
      bash start-cluster.sh
      docker container exec -d raft_${raft_id} bash fault_slowcpu.sh ${cpu_percent}
      docker run --rm --name rclient --net raftnet --ip 172.18.1.10 raft-client bash workload.sh ${N_THREADS}
      bash stop-cluster.sh
    fi
  done
done

# memory contention faults
MEM_LIMITS=(
  "6m"  # lowest limit
  "10m"
  "20m"
  "40m"
  "80m"
)
for ((i = 0; i < ${#RAFT_NODES[@]}; i++)) do
  read -a raft_node <<< ${RAFT_NODES[$i]}
  raft_name=${raft_node[0]}
  raft_id=${raft_node[1]}

  for ((j = 0; j < ${#MEM_LIMITS[@]}; j++)) do
    mem_limit=${MEM_LIMITS[$j]}
    echo ">>> Memory contention ${mem_limit} bytes [${raft_name}]"
    if [[ $1 == "run" ]]
    then
      bash start-cluster.sh ${raft_name} "--memory ${mem_limit}"
      docker run --rm --name rclient --net raftnet --ip 172.18.1.10 raft-client bash workload.sh ${N_THREADS}
      bash stop-cluster.sh
    fi
  done
done
