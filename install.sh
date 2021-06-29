#!/bin/bash

project_dir=/tmp/proxy-server/proxy-server-develop


rm -rf /tmp/proxy-server.zip /tmp/proxy-server

curl -fsSL https://github.com/Nick-Lu/proxy-server/archive/refs/heads/develop.zip --output /tmp/proxy-server.zip

mkdir /tmp/proxy-server

unzip /tmp/proxy-server.zip -d /tmp/proxy-server


sh $project_dir/install-v2ray.sh $0 $1

sh $project_dir/install-nginx.sh