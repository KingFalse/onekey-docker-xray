#!/bin/bash
set -e

DOMAIN=$1
EMAIL=$2

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

install_xray() {
  echo -e "\e[1;32m正在清理旧容器以及镜像...\e[0m"
  echo -e "\e[1;32m：${DOMAIN}\e[0m"
  if [ "$(docker ps -aq -f name=xray)" ]; then
    docker rm -f xray >/dev/null 2>&1
  fi
  echo -e "\e[1;32m您输入的域名是：${DOMAIN}\e[0m"

  echo -e "\e[1;32m正在启动docker容器...\e[0m"
  docker run --name xray -d --pull=always -p 443:443 -e PORT=443 -e DOMAIN=${DOMAIN} -e EMAIL=${EMAIL} kingfalse/onekey-docker-xray
  docker logs -f xray
  if [[ "$(docker container diff xray)" == *"ssl.key"* ]]; then
    echo -e "\e[1;32m证书初始化申请成功！\e[0m"
    docker container update xray --restart=always >/dev/null 2>&1
    docker restart xray >/dev/null 2>&1
  else
    echo -e "\e[1;31m似乎是申请证书出问题了，请你检查输出日志...\e[0m"
    exit 0
  fi

  echo -e "\e[1;32m完全卸载：docker rm -f xray\e[0m"
  echo -e "\e[1;32m查看链接：docker exec xray cat /srv/url.txt\e[0m"
  echo -e "\e[1;32m喜欢请给个星：https://github.com/KingFalse/onekey-docker-xray\e[0m"
}

do_install() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "\e[1;31m请使用root权限重新执行本脚本...\e[0m"
    exit
  fi

  if command_exists docker && [ -e /var/run/docker.sock ]; then
    echo -e "\e[1;32m本机已安装docker... \e[0m"
  else
    echo -e "\e[1;32m正在安装docker... \e[0m"
    curl -sSL https://get.docker.com/ | bash
  fi

  if command_exists docker && [ -e /var/run/docker.sock ]; then
    systemctl enable docker.service
    systemctl enable containerd.service
    systemctl start docker
    install_xray
  else
    echo -e "\e[1;31mdocker似乎安装失败，您可自行安装docker并重新运行本脚本 \e[0m"
  fi
}

do_install
