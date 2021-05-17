#!/bin/bash

V2RAY_VERSION=4.34.0

FILE_NAME=v2ray-linux-64.zip
TMP_ZIP_PATH=/tmp/${FILE_NAME}

__install_v2ray() {
  # Install requirements components
  apt-get install unzip -y

  # Download v2ray zip file from github releases
  curl -L https://github.com/v2fly/v2ray-core/releases/download/v${V2RAY_VERSION}/${FILE_NAME} --output ${TMP_ZIP_PATH}

  LIB_PATH=/usr/lib/v2ray-linux-64
  echo "Download and install v2ray-linux-64 to ${LIB_PATH}"
  unzip -o ${TMP_ZIP_PATH} -d ${LIB_PATH}

  echo "Create soft symbol link to /usr/bin/v2ray"
  ln -s -f ${LIB_PATH}/v2ray /usr/bin/v2ray
}

__config_proxy_server() {
  PORT=$1
  USER=$2
  PASS=$3

  cat >$V2RAY_CONFIG_FILE_PATH <<EOF
{
  "inbounds": [
    {
      "port": $PORT,
      "listen": "0.0.0.0",
      "tag": "socks-inbound",
      "protocol": "socks",
      "settings": {
        "auth": "password",
        "accounts": [
          {
            "user": ${USER},
            "pass": ${PASS}
          }
        ],
        "udp": False,
        "ip": "127.0.0.1"
      },
      "sniffing": {
        "enabled": True,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {},
      "tag": "direct"
    }
  ]
}
EOF

  echo "Generate v2ray config file to <${V2RAY_CONFIG_FILE_PATH}>"
}

__v2ray_as_server() {
  # Install V2Ray as service
  SERVICE_MODULE_FILE_URL=https://github.com/Robert-lihouyi/aws-image/raw/main/v2ray.service
  SERVICE_MODULE_PATH=/etc/systemd/system/v2ray.service

  curl -L ${SERVICE_MODULE_FILE_URL} --output ${SERVICE_MODULE_PATH}

  chmod 644 ${SERVICE_MODULE_PATH}

  echo "Enable service v2ray.service <${SERVICE_MODULE_PATH}>"
  /usr/bin/systemctl enable v2ray.service
}

if [ -n "$3" ]; then
  __install_v2ray
  __config_proxy_server $1 $2 $3
  __v2ray_as_server
else
  # 参数错误，退出
  echo "$(
    cat <<EOS

Usage:	$0 PORT USER PASS

EOS
  )
"
  exit
fi
