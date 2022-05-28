FROM teddysun/xray

LABEL maintainer="KingFalse <yzsl@live.com>"

USER 0

ENV TZ=Asia/Shanghai \
    DOMAIN=your.domain.com \
    PORT=443

WORKDIR /srv

ADD ./url.txt /srv/
ADD ./xray-server.sh /srv/
ADD ./xray-server.json /srv/

RUN apk --no-cache add -f \
      openssl \
      openssh-client \
      coreutils \
      bind-tools \
      sed \
      socat \
      tzdata \
      oath-toolkit-oathtool \
      tar \
      libidn \
      jq; \
    wget -O -  https://get.acme.sh | sh; \
    chmod +x /srv/xray-server.sh

CMD ["sh","/srv/xray-server.sh"]