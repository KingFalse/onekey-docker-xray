# onekey-docker-xray

**一键部署你的Xray服务,一次6个配置，哪个舒服用哪个**
1. VLESS over TCP with XTLS，数倍性能，首选方式
2. VLESS over TCP with TLS
3. VLESS over WS with TLS
4. VMess over TCP with TLS
5. VMess over WS with TLS
6. Trojan over TCP with TLS

### 快速安装

* 默认443端口：`curl -sSL https://raw.githubusercontent.com/KingFalse/onekey-docker-xray/main/install.sh | bash`

* 因为是自签证书,必须在客户端中将`跳过证书验证(allowInsecure)`选项设置为true

* 指定其他端口：`curl -sSL https://raw.githubusercontent.com/KingFalse/onekey-docker-xray/main/install.sh | bash -s 6379`

* 手动docker安装：`docker run --name xray -d --restart=always --pull=always -p 443:443 -e PORT=443 -e DOMAIN=服务器公网IP kingfalse/onekey-docker-xray`

### 查看链接

```
docker exec xray cat /srv/url.txt
```

### 完全卸载

```
docker rm -f xray
```

### 屏幕预览

![screenshot](screenshot/img.png)

### 其他

有问题提Issues,有需求也可
