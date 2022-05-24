#!/bin/sh

# 生成UUID，生成自签证书，设定端口
if [ ! -f "uuid" ]; then
  xray uuid >uid
  uuid=$(cat uid)
  xray tls cert --domain=$(DOMAIN) >ssl.json
  sed -i '/certificates/r ssl.json' xray-server.json
  sed -i 's/443/'$(PORT)'/' xray-server.json
  sed -i 's/UUID_UUID/'$(uuid)'/' xray-server.json
  sed -i 's/DOMAIN/'$(DOMAIN)'/' v2-server.json
  sed -i 's/your.domain.com/'$(DOMAIN)'/' v2-client.json
fi

xray run -c /srv/xray-server.json
