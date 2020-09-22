#!/bin/sh

set -xe

geth account plugin new \
      --plugins file:///qdata/dd/build/bin/geth-plugin-settings.json \
      --plugins.skipverify \
      --plugins.account.config '{"secretName": "demoacct","overwriteProtection": {"currentVersion": 0}}'

ls /tmp/accounts

vault kv get secret/demoacct

geth account plugin new \
      --plugins file:///qdata/dd/build/bin/geth-plugin-settings.json \
      --plugins.skipverify \
      --plugins.account.config '{"secretName": "anotherdemoacct","overwriteProtection": {"currentVersion": 0}}'

geth attach /qdata/dd/geth.ipc

personal.listWallets