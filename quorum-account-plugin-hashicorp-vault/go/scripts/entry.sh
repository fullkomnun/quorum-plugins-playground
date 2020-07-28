#!/bin/sh

set -xe

if ! test -f /qdata/dd/initialized; then

#    ./vault.sh

    # curl -v \
    # --header "X-Vault-Token: qwerty" \
    # --request POST \
    # --data '{"type": "approle"}' \
    # http://vault-server:8200/v1/sys/auth/approle

    # curl -v \
    # --header "X-Vault-Token: qwerty" \
    # --request PUT \
    # --data '{"policy": "path \"secret/*\" {capabilities = [\"create\", \"update\", \"read\"]}"}' \
    # http://vault-server:8200/v1/sys/policies/acl/basicpolicy

    # curl -v \
    # --header "X-Vault-Token: qwerty" \
    # --request POST \
    # --data '{"policies": "basicpolicy"}' \
    # http://vault-server:8200/v1/auth/approle/role/basicrole

    # roleId=$(curl -v -s \
    # --header "X-Vault-Token: qwerty" \
    # http://vault-server:8200/v1/auth/approle/role/basicrole/role-id | jq '.data.role_id')
    # export HASHICORP_ROLE_ID="${roleId}"

    # secretId=$(curl -v -s \
    # --header "X-Vault-Token: qwerty" \
    # --request POST \
    #   http://vault-server:8200/v1/auth/approle/role/basicrole/secret-id | jq '.data.secret_id')
    # export HASHICORP_SECRET_ID="${secretId}"

    # echo "HASHICORP_ROLE_ID=${HASHICORP_ROLE_ID}"
    # echo "HASHICORP_SECRET_ID=${HASHICORP_SECRET_ID}"

    mkdir -p /qdata/dd/build/bin/

#     cat <<EOF >/qdata/dd/build/bin/geth-plugin-settings.json
# {
#     "baseDir": "plugins-basedir",
#     "providers": {
#         "account": {
#             "name": "quorum-account-plugin-hashicorp-vault",
#             "version": "0.1.0",
#             "config": "file:///qdata/dd/build/bin/quorum-account-plugin-hashicorp-vault.json"
#         }
#     }
# }
# EOF

    mkdir -p /tmp/accounts
    cat <<EOF >/qdata/dd/build/bin/quorum-account-plugin-hashicorp-vault.json
{
    "vault": "http://vault-server:8200",
    "kvEngineName": "secret",
    "accountDirectory": "file:///tmp/accounts",
    "authentication": {
        "token": "env://VAULT_DEV_ROOT_TOKEN_ID"
    }
}
EOF

#     cat <<EOF >/qdata/dd/build/bin/quorum-account-plugin-hashicorp-vault.json
# {
#     "vault": "http://vault-server:8200",
#     "kvEngineName": "secret",
#     "accountDirectory": "file:///path/to/accts",
#     "authentication": {
#         "roleId": "env://HASHICORP_ROLE_ID",
#         "secretId": "env://HASHICORP_SECRET_ID",
#         "approlePath": "approle"
#     }
# }
# EOF

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
--raftport 50400 --rpc --rpcaddr 0.0.0.0 --rpcvhosts=* --rpcapi eth,debug,admin,net,web3,plugin@account \
--emitcheckpoints --port 30303 --plugins file:///qdata/dd/build/bin/geth-plugin-settings.json --plugins.skipverify