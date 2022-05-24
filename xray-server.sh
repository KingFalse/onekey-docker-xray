#!/bin/sh

# 生成UUID，生成自签证书，设定端口
if [ ! -f "uuid" ]; then
  xray uuid >uid
  uuid=$(cat uid)
  xray tls cert --domain=${DOMAIN} >ssl.json
  sed -i '/certificates/r ssl.json' xray-server.json
  sed -i 's/443/'${PORT}'/' xray-server.json
  sed -i 's/UUID_UUID/'${uuid}'/' xray-server.json
fi

# 生成链接信息
touch /srv/url.txt
# VLESS-TCP-XTLS
echo "vless://${uuid}@${DOMAIN}:${PORT}?security=xtls&encryption=none&headerType=none&type=tcp&flow=xtls-rprx-direct#VLESS-TCP-XTLS_${DOMAIN}" >>/srv/url.txt
# VLESS-TCP-TLS
echo "vless://${uuid}@${DOMAIN}:${PORT}?security=tls&encryption=none&headerType=none&type=tcp#VLESS-TCP-TLS_${DOMAIN}" >>/srv/url.txt
# VLESS-WS-TLS
echo "vless://${uuid}@${DOMAIN}:${PORT}?path=%2Fwebsocket&security=tls&encryption=none&type=ws#VLESS-WS-TLS_${DOMAIN}" >>/srv/url.txt
# VMESS-WS-TLS
echo "vmess://"$(echo '{"add":'"${DOMAIN}"',"aid":"0","host":"","id":"'${uuid}'","net":"ws","path":"/vmessws","port":"'${PORT}'","ps":"VMESS-WS-TLS_'${DOMAIN}'","scy":"none","sni":"","tls":"tls","type":"","v":"2"}' | base64 -w 0) >>/srv/url.txt
# VMESS-TCP-TLS
echo "vmess://"$(echo '{"add":'"${DOMAIN}"',"aid":"0","host":'"${DOMAIN}"',"id":"'${uuid}'","net":"tcp","path":"/vmesstcp","port":"'${PORT}'","ps":"VMESS-TCP-TLS_'${DOMAIN}'","scy":"none","sni":'"${DOMAIN}"',"tls":"tls","type":"http","v":"2"}' | base64 -w 0) >>/srv/url.txt
# Trojan-TCP-TLS
echo "trojan://${uuid}@${DOMAIN}:${PORT}?security=tls&headerType=none&type=tcp#Trojan-TCP-TLS_${DOMAIN}" >>/srv/url.txt

echo "链接信息："
echo ""
echo ""
echo ""
cat /srv/url.txt
echo ""
echo ""
echo ""

xray run -c /srv/xray-server.json
