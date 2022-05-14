#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
source ${parent_path}/utils.sh

# IP_PREFIX=127.0.0.1:2100
IP_PREFIX=172.18.0.11:2100

# set node 1 as leader and add others to the membership
# rpc ${IP_PREFIX}1/init '{}'
# rpc ${IP_PREFIX}1/add-learner "[2, \"${IP_PREFIX}2\"]"
# rpc ${IP_PREFIX}1/add-learner "[3, \"${IP_PREFIX}3\"]"
# rpc ${IP_PREFIX}1/add-learner "[4, \"${IP_PREFIX}4\"]"
# rpc ${IP_PREFIX}1/add-learner "[5, \"${IP_PREFIX}5\"]"
# rpc ${IP_PREFIX}1/metrics

rpc 172.18.0.11:21001/init '{}'
rpc 172.18.0.11:21001/add-learner "[2, \"172.18.0.12:21001\"]"
rpc 172.18.0.11:21001/add-learner "[3, \"172.18.0.13:21001\"]"
rpc 172.18.0.11:21001/add-learner "[4, \"172.18.0.14:21001\"]"
rpc 172.18.0.11:21001/add-learner "[5, \"172.18.0.15:21001\"]"
rpc 172.18.0.11:21001/change-membership '[1, 2, 3, 4, 5]'
rpc 172.18.0.11:21001/metrics