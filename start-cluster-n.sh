#!/bin/bash

# if [ "$#" -eq 2 ]
# then
#   if [[ $1 == "leader" ]]
#   then
#     LEADER_FLAGS=$2
#     echo "Using leader flags: ${LEADER_FLAGS}"
#   else
#     FOLLOWER_FLAGS=$2
#     echo "Using follower flags: ${FOLLOWER_FLAGS}"
#   fi
# fi

# NETWORK=host
# IP_PREFIX=127.0.0.1
# IP_DOCKER=""

NETWORK=raftnet
IP_PREFIX=172.18.0.11
IP_DOCKER="--ip ${IP_PREFIX}"

NUM_NODES=$1


echo ">>> Running ${NUM_NODES} raft containers"
for ((i = 1; i <= ${NUM_NODES}; i++)) do
  docker run -d --rm --cap-add ALL --init --name raft_${i} --net ${NETWORK} --ip 172.18.0.1${i} raft-kv tail -f /dev/null
done

echo ">>> Starting raft servers"
for ((i = 1; i <= ${NUM_NODES}; i++)) do
  docker container exec -d raft_${i} sh -c "raft-key-value --id ${i} --http-addr 172.18.0.1${i}:21001 --jaeger-agent 172.18.0.9:6831 2>& 1 | tee log.txt"
done
sleep 1

echo ">>> Connecting servers"
docker container exec raft_1 bash connect_n.sh ${NUM_NODES}

