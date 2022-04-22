#!/bin/bash

HOST_ID=$(shuf -i 1-5 -n 1)
KEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
VALUE=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16)
curl --silent "172.18.0.1${HOST_ID}:21001/write" -H "Content-Type: application/json" -d "{\"Set\":{\"key\":\"${KEY}\",\"value\":\"${VALUE}\"}}"

