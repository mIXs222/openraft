#!/bin/bash

if [ "$#" -ne 1 ]
then
  echo "Require one restart command, $# provided"
  exit 1
fi
RESTART_CMD=$1

echo "Clashing behavior with restart= ${RESTART_CMD}"
while true; do
  sleep 10
  killall raft-key-value
  nohup $RESTART_CMD &
done