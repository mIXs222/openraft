#!/bin/bash

echo ">>> Building raft server (raft-kv) image"
docker build -f raft-kv.Dockerfile -t raft-kv .

echo ">>> Building raft client (raft-client) image"
docker build -f raft-client.Dockerfile -t raft-client .

docker network inspect raftnet >/dev/null 2>&1 || ( 
    echo ">>> Creating docker network"
    docker network create --subnet=172.18.0.0/16 raftnet
)
