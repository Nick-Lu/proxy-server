#!/bin/bash

rm -rf /tmp/proxy-server.zip /tmp/proxy-server

curl -fsSL https://github.com/Nick-Lu/proxy-server/archive/refs/heads/develop.zip --output /tmp/proxy-server.zip

mkdir /tmp/proxy-server

unzip /tmp/proxy-server.zip -d /tmp/proxy-server


sh /tmp/proxy-server/install-v2ray.sh

sh /tmp/proxy-server/install-nginx.sh