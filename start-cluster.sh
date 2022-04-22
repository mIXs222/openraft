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

echo ">>> Running raft containers"
docker run -d --rm --init ${LEADER_FLAGS} --name raft_1 --net raftnet --ip 172.18.0.11 raft-kv tail -f /dev/null
docker run -d --rm --init ${FOLLOWER_FLAGS} --name raft_2 --net raftnet --ip 172.18.0.12 raft-kv tail -f /dev/null
docker run -d --rm --init --name raft_3 --net raftnet --ip 172.18.0.13 raft-kv tail -f /dev/null
docker run -d --rm --init --name raft_4 --net raftnet --ip 172.18.0.14 raft-kv tail -f /dev/null
docker run -d --rm --init --name raft_5 --net raftnet --ip 172.18.0.15 raft-kv tail -f /dev/null

echo ">>> Starting raft servers"
docker container exec -d raft_1 raft-key-value --id 1 --http-addr 172.18.0.11:21001
docker container exec -d raft_2 raft-key-value --id 2 --http-addr 172.18.0.12:21001
docker container exec -d raft_3 raft-key-value --id 3 --http-addr 172.18.0.13:21001
docker container exec -d raft_4 raft-key-value --id 4 --http-addr 172.18.0.14:21001
docker container exec -d raft_5 raft-key-value --id 5 --http-addr 172.18.0.15:21001
sleep 1

echo ">>> Connecting servers"
docker container exec raft_1 bash connect.sh
