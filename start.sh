#!/bin/sh

# configs
AUUID=de157513-c8b7-4c0c-84bd-bb74d1ea179d
CADDYIndexPage=https://github.com/AYJCSGM/mikutap/archive/master.zip
CONFIGCADDY=https://github.com/lqz2002/kinto/blob/main/etc/Caddyfile
CONFIGXRAY=https://github.com/lqz2002/kinto/blob/main/etc/kinto.json
ParameterSSENCYPT=chacha20-ietf-poly1305
StoreFiles=https://github.com/lqz2002/kinto/blob/main/etc/StoreFiles
#PORT=4433
mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt
wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/
wget -qO- $CONFIGCADDY | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile
wget -qO- $CONFIGXRAY | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/xray.json

# storefiles
mkdir -p /usr/share/caddy/$AUUID && wget -O /usr/share/caddy/$AUUID/StoreFiles $StoreFiles
wget -P /usr/share/caddy/$AUUID -i /usr/share/caddy/$AUUID/StoreFiles

for file in $(ls /usr/share/caddy/$AUUID); do
    [[ "$file" != "StoreFiles" ]] && echo \<a href=\""$file"\" download\>$file\<\/a\>\<br\> >>/usr/share/caddy/$AUUID/ClickToDownloadStoreFiles.html
done

# start
tor &

/kinto -config /kinto.json &

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
