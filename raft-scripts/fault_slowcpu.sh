#!/bin/bash

if [ "$#" -ne 1 ]
then
  echo "Require allowed cpu percentage, $# provided"
  exit 1
fi
CPU_PERCENT=$1

echo "Slowing down cpu"
cpulimit -e raft-key-value -l ${CPU_PERCENT}
