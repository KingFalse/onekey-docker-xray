FROM teddysun/xray

LABEL maintainer="KingFalse <yzsl@live.com>"

USER 0

ENV PASSWORD=PASSWORD \
    PORT=11443

WORKDIR /srv

ADD ./xray-server.sh /srv/
ADD ./config.json /srv/

RUN chmod +x /srv/xray-server.sh

CMD ["sh","/srv/xray-server.sh"]