FROM teddysun/xray

LABEL maintainer="KingFalse <yzsl@live.com>"

USER 0

ENV DOMAIN=your.domain.com
ENV PORT=443
WORKDIR /srv

ADD ./xray-server.json /srv/

RUN set -eux; \
    chmod +x v2-server.sh

CMD ["sh","/srv/xray-server.sh"]