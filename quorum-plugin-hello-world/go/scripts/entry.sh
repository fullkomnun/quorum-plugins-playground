#!/bin/sh

set -xe

if ! test -f /qdata/dd/initialized; then
    mkdir -p /qdata/dd/
    cd /qdata/dd/ || exit
    bootnode --genkey=nodekey
    nodeAddr=$(bootnode --nodekey=nodekey --writeaddress)
    echo "[
      \"enode://${nodeAddr}@0.0.0.0:30303?discport=0&raftport=50400\"
    ]" > static-nodes.json

    echo "Quorum initializing..."
    geth --datadir=/qdata/dd --nousb init /qdata/dd/genesis.json

    touch /qdata/dd/initialized
    echo "Quorum is now initialized"
    ls /qdata/dd/
    cat /qdata/dd/nodekey
    cat /qdata/dd/static-nodes.json
else
    echo "Quorum already initialized, skipping..."
fi

geth --datadir /qdata/dd --nodiscover --networkid 10 --txpool.pricelimit 0 --verbosity 6 --nousb --raft \
--raftport 50400 --rpc --rpcaddr 0.0.0.0 --rpcvhosts=* --rpcapi eth,debug,admin,net,web3,plugin@helloworld \
--emitcheckpoints --port 30303 --plugins file:///qdata/dd/build/bin/geth-plugin-settings.json --plugins.skipverify