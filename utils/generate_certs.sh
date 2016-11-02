#!/bin/bash

command_exists () {
    type "$1" &> /dev/null ;
}

if ! command_exists flocker-ca; then
    echo "Please install flocker-ca"
    exit 1
fi

if [ ! -d certs ]; then
    mkdir certs >/dev/null 2>&1
fi

cd certs
flocker-ca initialize cluster >/dev/null 2>&1
flocker-ca create-control-certificate aws-100  >/dev/null 2>&1
mv control-aws-100.crt control-service.crt >/dev/null 2>&1
mv control-aws-100.key control-service.key >/dev/null 2>&1

flocker-ca create-api-certificate plugin >/dev/null 2>&1
flocker-ca create-api-certificate client >/dev/null 2>&1

for i in `docker-machine ls -q`; do
    flocker-ca create-node-certificate >/dev/null 2>&1
    for f in `ls -ltr | tail -2 | awk '{print $9;}'`; do
        mv "${f%.*}".crt "node-$i".crt >/dev/null 2>&1
        mv "${f%.*}".key "node-$i".key >/dev/null 2>&1
    done
done
