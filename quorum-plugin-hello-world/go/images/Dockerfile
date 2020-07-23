FROM golang:1.13-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git zip perl-utils

WORKDIR /
RUN git clone --recursive https://github.com/jpmorganchase/quorum-plugin-hello-world.git && cd quorum-plugin-hello-world/go && make

FROM quorumengineering/quorum:latest

RUN mkdir -p /qdata/dd/build/bin/

COPY --from=builder /quorum-plugin-hello-world/go/hello-world-plugin-config.json /qdata/dd/build/bin

COPY --from=builder /quorum-plugin-hello-world/go/build/linux-amd64/quorum-plugin-hello-world-*.zip /qdata/dd/build/bin

RUN echo $' \
{ \n\
  "baseDir": "./build/bin", \n\
  "providers": { \n\
    "helloworld": { \n\
      "name":"quorum-plugin-hello-world", \n\
      "version":"1.0.0", \n\
      "config": "file:///qdata/dd/build/bin/hello-world-plugin-config.json" \n\
    } \n\
  } \n\
} \
EOF' >> /qdata/dd/build/bin/geth-plugin-settings.json