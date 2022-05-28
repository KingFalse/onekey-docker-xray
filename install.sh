#!/bin/bash
set -e

DOMAIN=$1
EMAIL=$2

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

install_xray() {
  echo "正在清理旧容器以及镜像..."
  if [ "$(docker ps -aq -f name=xray)" ]; then
    docker rm -f xray >/dev/null 2>&1
  fi
  echo "您输入的域名是："${DOMAIN}

  echo "正在启动docker容器..."
  docker run --name xray -d --pull=always -p 443:443 -e PORT=443 -e DOMAIN=${DOMAIN} -e EMAIL=${EMAIL} kingfalse/onekey-docker-xray
  #  --restart=always
  docker logs -f xray
  echo "-----------------"
  docker container diff xray
#  docker container diff xray | grep "/srv/ssl.key" >>/dev/null
#  if [ $? -ne 0 ]; then
#    echo "似乎是申请证书出问题了，请你检查输出日志..."
#    docker rm -f xray >/dev/null 2>&1
#    exit 0
#  else
#    echo "xxxxxxxxxxxxxxxxxx"
#  fi

  echo "请复制您的链接信息："
  echo ""
  echo ""
  docker exec xray cat /srv/url.txt
  echo ""
  echo ""
  echo "完全卸载：docker rm -f xray"
  echo "查看链接：docker exec xray cat /srv/url.txt"
  echo "喜欢请给个星：https://github.com/KingFalse/onekey-docker-xray"
}

do_install() {
  if [ "$EUID" -ne 0 ]; then
    echo "请使用root权限重新执行本脚本..."
    exit
  fi

  if command_exists docker && [ -e /var/run/docker.sock ]; then
    echo "本机已安装docker..."
  else
    echo "正在安装docker..."
    curl -sSL https://get.docker.com/ | bash
  fi

  if command_exists docker && [ -e /var/run/docker.sock ]; then
    systemctl enable docker.service
    systemctl enable containerd.service
    systemctl start docker
    install_xray
  else
    echo "docker似乎安装失败，您可自行安装docker并重新运行本脚本"
  fi
}

do_install
