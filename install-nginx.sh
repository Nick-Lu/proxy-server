#!/bin/bash

self_dir=$(cd `dirname $0`; pwd)

# 版本
tengine_version=tengine-2.3.3
# 文件名
file_name=$tengine_version.tar.gz
# 下载地址
nginx_package=http://tengine.taobao.org/download/$file_name
# 临时文件
tmp_file=/tmp/$file_name


# 安装 nginx
__install_nginx(){
  echo "Install require packages..."
  sudo apt-get install libpcre3 libpcre3-dev openssl libssl-dev gcc g++ make zlib1g-dev -y

  echo "Download tengine..."
  curl -fsSL $nginx_package --output $tmp_file

  echo "Install tengine..."
  tar -xf $tmp_file -C /tmp

  cd /tmp/$tengine_version
    sh ./configure
    make
    make install
  cd - 
  echo "Install tengine successful"
}

__nginx_as_server() {
  echo "Install nginx as service ..."
  # Install nginx as service
  SERVICE_MODULE_PATH=/etc/systemd/system/nginx.service

  cp $self_dir/nginx.service ${SERVICE_MODULE_PATH}

  chmod 644 ${SERVICE_MODULE_PATH}

  echo "Enable service nginx.service <${SERVICE_MODULE_PATH}>"
  /usr/bin/systemctl enable nginx.service
  /usr/bin/systemctl restart nginx.service
}

__config_nginx(){
  cp $self_dir/config/nginx.conf /usr/local/nginx/conf
  sed '/drop-off-instance.edecker.local/d' /etc/hosts
  echo "127.0.0.1 drop-off-instance.edecker.local" >> /etc/hosts
}



__install_nginx
__config_nginx
__nginx_as_server
