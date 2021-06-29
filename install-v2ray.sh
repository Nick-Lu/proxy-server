#!/bin/bash
self_dir=$(cd `dirname $0`; pwd)

V2RAY_VERSION=4.34.0

FILE_NAME=v2ray-linux-64.zip
ARM_FILE_NAME=v2ray-linux-arm64-v8a.zip

TMP_ZIP_PATH=/tmp/${FILE_NAME}
__install_v2ray() {
  # Install requirements components
  apt-get install unzip -y


  # Download v2ray zip file from github releases
  case $(uname -m) in
      x86_64)
        curl -fsSL https://github.com/v2fly/v2ray-core/releases/download/v${V2RAY_VERSION}/${FILE_NAME} --output ${TMP_ZIP_PATH}
      ;;
      aarch64) 
        curl -fsSL https://github.com/v2fly/v2ray-core/releases/download/v${V2RAY_VERSION}/${ARM_FILE_NAME} --output ${TMP_ZIP_PATH}
      ;;
  esac

  LIB_PATH=/usr/lib/v2ray-linux-64
  echo "Download and install v2ray-linux-64 to ${LIB_PATH}"
  unzip -q -o ${TMP_ZIP_PATH} -d ${LIB_PATH}

  echo "Create soft symbol link to /usr/bin/v2ray"
  ln -s -f ${LIB_PATH}/v2ray /usr/bin/v2ray
}

__config_proxy_server() {
  USER=$1
  PASS=$2

  cat >/etc/v2ray.json <<EOF
{
  "inbounds": [
    {
      "port": 1080,
      "listen": "0.0.0.0",
      "tag": "socks-inbound",
      "protocol": "socks",
      "settings": {
        "auth": "password",
        "accounts": [
          {
            "user": "${USER}",
            "pass": "${PASS}"
          }
        ],
        "udp": false,
        "ip": "127.0.0.1"
      }
    },
    {
      "protocol": "shadowsocks",
      "port": 1081,
      "listen": "0.0.0.0",
      "tag": "shadowsocks-inbound",
      "settings": {
        "method": "aes-256-gcm",
        "password": "${PASS}",
        "network": "tcp",
        "ivCheck": true
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

  echo "Generate v2ray config file to /etc/v2ray.json"
}

__v2ray_as_server() {
  # Install V2Ray as service
  SERVICE_MODULE_PATH=/etc/systemd/system/v2ray.service

  cp $self_dir/v2ray.service ${SERVICE_MODULE_PATH}

  chmod 644 ${SERVICE_MODULE_PATH}

  echo "Enable service v2ray.service <${SERVICE_MODULE_PATH}>"
  /usr/bin/systemctl enable v2ray.service
  /usr/bin/systemctl restart v2ray.service
}

if [ -n "$2" ]; then
  __install_v2ray
  __config_proxy_server $1 $2
  __v2ray_as_server
else
  # 参数错误，退出
  echo "$(
    cat <<EOS

Usage:	$0 USER PASS

EOS
  )
"
  exit
fi
