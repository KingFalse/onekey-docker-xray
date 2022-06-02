#!/bin/sh

INIT_SSL=1

# 证书不存在则生成新证书
if [ ! -f "/srv/ssl.key" ]; then
  INIT_SSL=0
  /root/.acme.sh/acme.sh --issue --alpn --tlsport 443 --days 1 -d ${DOMAIN} --keylength ec-256 --standalone --server letsencrypt -m ${EMAIL} --force --fullchain-file /srv/fullchain.cer --key-file /srv/ssl.key
  sed -i 's/443/80/' /root/.acme.sh/${DOMAIN}*/*.conf
fi
if [ ! -f "/srv/ssl.key" ]; then
  echo "申请SSL证书失败！"
  exit 1
fi
# 生成UUID，生成SSL证书，设定端口
if [ ! -f "uid" ]; then
  xray uuid >uid
  uuid=$(cat uid)
  sed -i 's/443/'${PORT}'/' xray-server.json
  sed -i 's/UUID_UUID/'${uuid}'/' xray-server.json

  # 生成链接信息
  sed -i 's/UUID/'${uuid}'/' url.txt
  sed -i 's/PORT/'${PORT}'/' url.txt
  sed -i 's/DOMAIN/'${DOMAIN}'/' url.txt
  sed -i 's/$/&'${DOMAIN}'/g' url.txt
  # VMESS-WS-TLS
  echo "vmess://"$(echo '{"add":'"${DOMAIN}"',"aid":"0","host":"","id":"'${uuid}'","net":"ws","path":"/vmessws","port":"'${PORT}'","ps":"VMESS-WS-TLS_'${DOMAIN}'","scy":"none","sni":"","tls":"tls","type":"","v":"2"}' | base64 -w 0) >>/srv/url.txt
  # VMESS-TCP-TLS
  echo "vmess://"$(echo '{"add":'"${DOMAIN}"',"aid":"0","host":'"${DOMAIN}"',"id":"'${uuid}'","net":"tcp","path":"/vmesstcp","port":"'${PORT}'","ps":"VMESS-TCP-TLS_'${DOMAIN}'","scy":"none","sni":'"${DOMAIN}"',"tls":"tls","type":"http","v":"2"}' | base64 -w 0) >>/srv/url.txt

  echo -e "\e[1;32m请复制您的链接信息：\e[0m"
  echo ""
  echo ""
  echo ""
  echo -e "\e[1;32m$(cat /srv/url.txt)\e[0m"
  echo ""
  echo ""
  echo ""

  mkdir -p /srv/webroot/${uuid}
  cp url.txt /srv/webroot/${uuid}/
  echo -e "\e[1;32m您也可以访问此链接获取以上链接内容：\e[0m"
  echo -e "\e[1;33mhttps://${DOMAIN}/${uuid}/url.txt\e[0m"
fi

if [ $INIT_SSL -eq 0 ]; then
  if [ -f "/srv/ssl.key" ]; then
    exit
  fi
fi

httpd -p 127.0.0.1:8080 -h /srv/webroot
xray run -c /srv/xray-server.json
