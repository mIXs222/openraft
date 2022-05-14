#!/bin/bash

# IP_PREFIX=127.0.0.1:2100
IP_PREFIX=172.18.0.11:2100

HOST_ID=$(shuf -i 1-5 -n 1)
KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
VALUE=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
# curl --silent "${IP_PREFIX}${HOST_ID}/write" -H "Content-Type: application/json" -d "{\"Set\":{\"key\":\"${KEY}\",\"value\":\"${VALUE}\"}}"
curl --silent "172.18.0.1${HOST_ID}:21001/write" -H "Content-Type: application/json" -d "{\"Set\":{\"key\":\"${KEY}\",\"value\":\"${VALUE}\"}}"

