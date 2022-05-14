#!/bin/bash

NUM_NODES=$1

write() {
  NUM_NODES=$1

  # IP_PREFIX=127.0.0.1:2100
  IP_PREFIX=172.18.0.11:2100

  HOST_ID=$(shuf -i 1-${NUM_NODES} -n 1)
  KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
  VALUE=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
  # curl --silent "${IP_PREFIX}${HOST_ID}/write" -H "Content-Type: application/json" -d "{\"Set\":{\"key\":\"${KEY}\",\"value\":\"${VALUE}\"}}"
  curl --max-time 5 --fail --silent "172.18.0.1${HOST_ID}:21001/write" -H "Content-Type: application/json" -d "{\"Set\":{\"key\":\"${KEY}\",\"value\":\"${VALUE}\"}}"
}

write ${NUM_NODES}
exit 0
