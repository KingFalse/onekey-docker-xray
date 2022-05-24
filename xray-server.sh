#!/bin/sh

# 生成UUID，生成自签证书，设定端口
if [ ! -f "uuid" ]; then
  xray uuid >uid
  uuid=$(cat uid)
  xray tls cert --domain=$(DOMAIN) >ssl.json
  sed -i '/certificates/r ssl.json' xray-server.json
  sed -i 's/$(PORT)/'$(PORT)'/' xray-server.json
  sed -i 's/UUID_UUID/'$(uuid)'/' xray-server.json
  sed -i 's/DOMAIN/'$(DOMAIN)'/' v2-server.json
  sed -i 's/your.domain.com/'$(DOMAIN)'/' v2-client.json
fi

# 生成链接信息
# VLESS-TCP-XTLS
echo "vless://$(uuid)@$(DOMAIN):$(PORT)?security=xtls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-direct#VLESS-TCP-XTLS_$(DOMAIN)" >>url.txt
# VLESS-TCP-TLS
echo "vless://$(uuid)@$(DOMAIN):$(PORT)?security=tls&encryption=none&headerType=none&type=tcp#VLESS-TCP-TLS_$(DOMAIN)" >>url.txt
# VLESS-WS-TLS
echo "vless://$(uuid)@$(DOMAIN):$(PORT)?path=%2Fwebsocket&security=tls&encryption=none&type=ws#VLESS-WS-TLS_$(DOMAIN)" >>url.txt
# VMESS-WS-TLS
echo "vmess://"$(echo '{"add":'"$(DOMAIN)"',"aid":"0","host":"","id":"'$(uuid)'","net":"ws","path":"/vmessws","port":"'$(PORT)'","ps":"VMESS-WS-TLS_'$(DOMAIN)'","scy":"none","sni":"","tls":"tls","type":"","v":"2"}' | base64 -w 0) >>url.txt
# VMESS-TCP-TLS
echo "vmess://"$(echo '{"add":'"$(DOMAIN)"',"aid":"0","host":'"$(DOMAIN)"',"id":"'$(uuid)'","net":"tcp","path":"/vmesstcp","port":"'$(PORT)'","ps":"VMESS-TCP-TLS_'$(DOMAIN)'","scy":"none","sni":'"$(DOMAIN)"',"tls":"tls","type":"http","v":"2"}' | base64 -w 0) >>url.txt
# Trojan-TCP-TLS
echo "trojan://$(uuid)@$(DOMAIN):$(PORT)?security=tls&headerType=none&type=tcp#Trojan-TCP-TLS_$(DOMAIN)" >>url.txt

xray run -c /srv/xray-server.json
