#!/bin/bash

NUM_NODES=$1
for ((i = 1; i <= ${NUM_NODES}; i++)) do
  docker stop raft_${i}
done