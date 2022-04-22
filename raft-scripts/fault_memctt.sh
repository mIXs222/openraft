#!/bin/bash

# FAIL: setting address space after lauching crash the raft server

if [ "$#" -ne 1 ]
then
  echo "Require allowed memory (bytes), $# provided"
  exit 1
fi
MEM_LIMIT=$1

echo "Simulating memory contention"
prlimit --pid $(pidof raft-key-value) --as=${MEM_LIMIT}:

# 30 MB: 31457280
# 40 MB: 41943040
# 50 MB: 52428800
