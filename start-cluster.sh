#!/bin/bash

if [ "$#" -eq 2 ]
then
  if [[ $1 == "leader" ]]
  then
    LEADER_FLAGS=$2
    echo "Using leader flags: ${LEADER_FLAGS}"
  else
    FOLLOWER_FLAGS=$2
    echo "Using follower flags: ${FOLLOWER_FLAGS}"
  fi
fi

# NETWORK=host
# IP_PREFIX=127.0.0.1
# IP_DOCKER=""

NETWORK=raftnet
IP_PREFIX=172.18.0.11
IP_DOCKER="--ip ${IP_PREFIX}"


echo ">>> Running raft containers"
# docker run -d --rm --cap-add ALL --init ${LEADER_FLAGS} --name raft_1 --net ${NETWORK} ${IP_DOCKER} raft-kv tail -f /dev/null
# docker run -d --rm --cap-add ALL --init ${FOLLOWER_FLAGS} --name raft_2 --net ${NETWORK} ${IP_DOCKER} raft-kv tail -f /dev/null
# docker run -d --rm --cap-add ALL --init --name raft_3 --net ${NETWORK} ${IP_DOCKER} raft-kv tail -f /dev/null
# docker run -d --rm --cap-add ALL --init --name raft_4 --net ${NETWORK} ${IP_DOCKER} raft-kv tail -f /dev/null
# docker run -d --rm --cap-add ALL --init --name raft_5 --net ${NETWORK} ${IP_DOCKER} raft-kv tail -f /dev/null

docker run -d --rm --cap-add ALL --init ${LEADER_FLAGS} --name raft_1 --net ${NETWORK} --ip 172.18.0.11 raft-kv tail -f /dev/null
docker run -d --rm --cap-add ALL --init ${FOLLOWER_FLAGS} --name raft_2 --net ${NETWORK} --ip 172.18.0.12 raft-kv tail -f /dev/null
docker run -d --rm --cap-add ALL --init --name raft_3 --net ${NETWORK} --ip 172.18.0.13 raft-kv tail -f /dev/null
docker run -d --rm --cap-add ALL --init --name raft_4 --net ${NETWORK} --ip 172.18.0.14 raft-kv tail -f /dev/null
docker run -d --rm --cap-add ALL --init --name raft_5 --net ${NETWORK} --ip 172.18.0.15 raft-kv tail -f /dev/null

echo ">>> Starting raft servers"
# docker container exec -d raft_1 raft-key-value --id 1 --http-addr ${IP_PREFIX}:21001
# docker container exec -d raft_2 raft-key-value --id 2 --http-addr ${IP_PREFIX}:21002
# docker container exec -d raft_3 raft-key-value --id 3 --http-addr ${IP_PREFIX}:21003
# docker container exec -d raft_4 raft-key-value --id 4 --http-addr ${IP_PREFIX}:21004
# docker container exec -d raft_5 raft-key-value --id 5 --http-addr ${IP_PREFIX}:21005

docker container exec -d raft_1 sh -c "raft-key-value --id 1 --http-addr 172.18.0.11:21001 --jaeger-agent 172.18.0.9:6831 2>& 1 | tee log.txt"
docker container exec -d raft_2 sh -c "raft-key-value --id 2 --http-addr 172.18.0.12:21001 --jaeger-agent 172.18.0.9:6831 2>& 1 | tee log.txt"
docker container exec -d raft_3 sh -c "raft-key-value --id 3 --http-addr 172.18.0.13:21001 --jaeger-agent 172.18.0.9:6831 2>& 1 | tee log.txt"
docker container exec -d raft_4 sh -c "raft-key-value --id 4 --http-addr 172.18.0.14:21001 --jaeger-agent 172.18.0.9:6831 2>& 1 | tee log.txt"
docker container exec -d raft_5 sh -c "raft-key-value --id 5 --http-addr 172.18.0.15:21001 --jaeger-agent 172.18.0.9:6831 2>& 1 | tee log.txt"
sleep 1

echo ">>> Connecting servers"
docker container exec raft_1 bash connect.sh
