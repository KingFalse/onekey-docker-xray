#!/bin/sh

# 证书不存在则生成新证书
if [ ! -f "/srv/ssl.key" ]; then
  /root/.acme.sh/acme.sh --issue --alpn --tlsport 80 --days 1 -d ${DOMAIN} --use-wget --keylength ec-256 --standalone --server letsencrypt --force --fullchain-file /srv/fullchain.cer --key-file /srv/ssl.key
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

  echo "链接信息："
  echo ""
  echo ""
  echo ""
  cat /srv/url.txt
  echo ""
  echo ""
  echo ""
fi

xray run -c /srv/xray-server.json
