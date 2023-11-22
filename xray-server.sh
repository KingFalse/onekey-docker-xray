#!/bin/sh

sed -i "s/99999/$PORT/g" /srv/config.json
sed -i "s/PASSWORD_PASSWORD/$PASSWORD/g" /srv/config.json
xray run -c /srv/config.json
