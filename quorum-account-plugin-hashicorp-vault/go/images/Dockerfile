FROM golang:1.13-alpine as builder

RUN apk add --no-cache git make gcc libc-dev zip perl-utils

WORKDIR /
RUN git clone --depth 1 --branch v0.1.0 https://github.com/jpmorganchase/quorum-account-plugin-hashicorp-vault.git && cd quorum-account-plugin-hashicorp-vault && make

FROM quorumengineering/quorum:latest

RUN apk add --no-cache curl jq

RUN mkdir -p /qdata/dd/build/bin/

COPY --from=builder /quorum-account-plugin-hashicorp-vault/build/dist/quorum-account-plugin-hashicorp-vault-*.zip /qdata/dd/build/bin

RUN echo $' \
{ \n\
  "baseDir": "./build/bin", \n\
  "providers": { \n\
    "account": { \n\
      "name":"quorum-account-plugin-hashicorp-vault", \n\
      "version":"0.1.0", \n\
      "config": "file:///qdata/dd/build/bin/quorum-account-plugin-hashicorp-vault.json" \n\
    } \n\
  } \n\
} \
EOF' >> /qdata/dd/build/bin/geth-plugin-settings.json