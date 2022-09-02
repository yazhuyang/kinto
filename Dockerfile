FROM alpine:edge

RUN apk update && \
    apk add --no-cache ca-certificates caddy tor zip unzip wget && \
    wget -O kinto.zip https://github.com/lqz2002/kinto/blob/main/kinto.zip && \
    unzip kinto.zip && \
    chmod +x /kinto && \
    rm -rf /var/cache/apk/*

ADD start.sh /start.sh
RUN chmod +x /start.sh

CMD /start.sh
