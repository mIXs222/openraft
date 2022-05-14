#/!bin/bash

int_handler() {
    echo "Interrupted."
    kill $PPID
    bash stop-cluster-n.sh 7
    docker kill rclient
    exit 1
}
trap 'int_handler' INT

if [[ $1 != "run" ]]
then
  echo "Running in mock mode, say \"run\" to execute the experiments"
fi

N_THREADS=1
echo ">>> N_THREADS= ${N_THREADS}"

WAIT_TIME_S=60
mkdir dep

# NETWORK=host
# IP_PREFIX=127.0.0.1:2100
# IP_CLIENT=127.0.0.1

NETWORK=raftnet
IP_PREFIX=172.18.0.1
IP_CLIENT=172.18.0.10

# normal serving
NUM_NODES=(
  # "1"
  # "3"
  # "5"
  "7"
)
for ((i = 0; i < ${#NUM_NODES[@]}; i++)) do
  num_nodes=${NUM_NODES[$i]}

  echo ">>> Experiment with ${num_nodes} nodes"
  if [[ $1 == "run" ]] || [[ $1 == "serving" ]]
  then
    bash start-cluster-n.sh ${num_nodes}

    # start client
    docker run --rm --name rclient --net ${NETWORK} --ip ${IP_CLIENT} raft-client bash workload_n.sh ${N_THREADS} ${num_nodes} 1000000 &
    client_pid=$!

    # wait a bit
    sleep ${WAIT_TIME_S}

    # collect data
    docker cp raft_1:/app/dependency_summary.jsons dep/serving_${num_nodes}_${N_THREADS}.jsons

    # stop everything
    # kill -9 ${client_pid}
    docker kill rclient
    bash stop-cluster-n.sh ${num_nodes}
  fi
done


# FAULT: network loss
NETEM_LOSSES=(
  "50"  # 50%
  "75"  # 25%
  "87.5"  # 12.5%
  "93.75"  # 6.25%
)
for ((i = 0; i < ${#NUM_NODES[@]}; i++)) do
  num_nodes=${NUM_NODES[$i]}
  for ((j = 0; j < ${#NETEM_LOSSES[@]}; j++)) do
    netem_loss=${NETEM_LOSSES[$j]}

    echo ">>> Experiment with ${num_nodes} nodes under ${netem_loss}% network loss"
    if [[ $1 == "run" ]] || [[ $1 == "netem" ]]
    then
      bash start-cluster-n.sh ${num_nodes}

      # start client
      docker run --rm --name rclient --net ${NETWORK} --ip ${IP_CLIENT} raft-client bash workload_n.sh ${N_THREADS} ${num_nodes} 1000000 &
      client_pid=$!

      # netem by pumba
      pumba netem -d ${WAIT_TIME_S}s loss -p ${netem_loss} re2:raft_* &
      netem_pid=$!

      # wait a bit
      sleep ${WAIT_TIME_S}

      # collect data
      docker cp raft_1:/app/dependency_summary.jsons dep/netem_${num_nodes}_${N_THREADS}_${netem_loss}.jsons

      # stop everything
      # kill -9 ${client_pid}
      docker kill rclient
      # kill -9 ${netem_pid}
      bash stop-cluster-n.sh ${num_nodes}
    fi
  done
done

# FAULT: netem without serving
for ((i = 0; i < ${#NUM_NODES[@]}; i++)) do
  num_nodes=${NUM_NODES[$i]}
  for ((j = 0; j < ${#NETEM_LOSSES[@]}; j++)) do
    netem_loss=${NETEM_LOSSES[$j]}

    echo ">>> Experiment with ${num_nodes} nodes under ${netem_loss}% network loss (no workload)"
    if [[ $1 == "run" ]] || [[ $1 == "netem-bg" ]]
    then
      bash start-cluster-n.sh ${num_nodes}

      # netem by pumba
      pumba netem -d ${WAIT_TIME_S}s loss -p ${netem_loss} re2:raft_* &
      netem_pid=$!

      # wait a bit
      sleep ${WAIT_TIME_S}

      # collect data
      docker cp raft_1:/app/dependency_summary.jsons dep/netem_${num_nodes}_0_${netem_loss}.jsons

      # stop everything
      # kill -9 ${client_pid}
      # kill -9 ${netem_pid}
      bash stop-cluster-n.sh ${num_nodes}
    fi
  done
done

# FAULT: netem corruption
NETEM_CORRUPTS=(
  "50"  # 50%
  "75"  # 25%
  "87.5"  # 12.5%
  "93.75"  # 6.25%
)
for ((i = 0; i < ${#NUM_NODES[@]}; i++)) do
  num_nodes=${NUM_NODES[$i]}
  for ((j = 0; j < ${#NETEM_CORRUPTS[@]}; j++)) do
    netem_corrupt=${NETEM_CORRUPTS[$j]}

    echo ">>> Experiment with ${num_nodes} nodes under ${netem_corrupt}% network corruption"
    if [[ $1 == "run" ]] || [[ $1 == "netem-cr" ]]
    then
      bash start-cluster-n.sh ${num_nodes}

      # start client
      docker run --rm --name rclient --net ${NETWORK} --ip ${IP_CLIENT} raft-client bash workload_n.sh ${N_THREADS} ${num_nodes} 1000000 &
      client_pid=$!

      # netem by pumba
      pumba netem -d ${WAIT_TIME_S}s corrupt -p ${netem_corrupt} re2:raft_* &
      # pumba netem -d ${WAIT_TIME_S}s loss -p ${netem_corrupt} corrupt -p ${netem_corrupt} duplicate -p ${netem_corrupt} re2:raft_* &
      netem_pid=$!

      # wait a bit
      sleep ${WAIT_TIME_S}

      # collect data
      docker cp raft_1:/app/dependency_summary.jsons dep/crnetem_${num_nodes}_1_${netem_corrupt}.jsons

      # stop everything
      # kill -9 ${client_pid}
      docker kill rclient
      # kill -9 ${netem_pid}
      bash stop-cluster-n.sh ${num_nodes}
    fi
  done
done

# # slow cpu faults
# CPU_PERCENTS=(
#   "1"
#   "2"
#   "4"
#   "8"
#   "16"
# )
# for ((i = 0; i < ${#RAFT_NODES[@]}; i++)) do
#   read -a raft_node <<< ${RAFT_NODES[$i]}
#   raft_name=${raft_node[0]}
#   raft_id=${raft_node[1]}

#   for ((j = 0; j < ${#CPU_PERCENTS[@]}; j++)) do
#     cpu_percent=${CPU_PERCENTS[$j]}
#     echo ">>> Slow CPU ${cpu_percent}% [${raft_name}]"
#     if [[ $1 == "run" ]]
#     then
#       bash start-cluster.sh
#       docker container exec -d raft_${raft_id} bash fault_slowcpu.sh ${cpu_percent}
#       docker run --rm --name rclient --net ${NETWORK} --ip ${IP_CLIENT} raft-client bash workload.sh ${N_THREADS}
#       bash stop-cluster.sh
#     fi
#   done
# done

# # memory contention faults
# MEM_LIMITS=(
#   "6m"  # lowest limit
#   "10m"
#   "20m"
#   "40m"
#   "80m"
# )
# for ((i = 0; i < ${#RAFT_NODES[@]}; i++)) do
#   read -a raft_node <<< ${RAFT_NODES[$i]}
#   raft_name=${raft_node[0]}
#   raft_id=${raft_node[1]}

#   for ((j = 0; j < ${#MEM_LIMITS[@]}; j++)) do
#     mem_limit=${MEM_LIMITS[$j]}
#     echo ">>> Memory contention ${mem_limit} bytes [${raft_name}]"
#     if [[ $1 == "run" ]]
#     then
#       bash start-cluster.sh ${raft_name} "--memory ${mem_limit}"
#       docker run --rm --name rclient --net ${NETWORK} --ip ${IP_CLIENT} raft-client bash workload.sh ${N_THREADS}
#       bash stop-cluster.sh
#     fi
#   done
# done
