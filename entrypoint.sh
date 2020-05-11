#!/bin/bash

SGID=`getent group i2psvc | cut -d: -f3`
SUID=`id -u i2psvc`

if [[ "$PGID" != "" && "$SGID" != "$PGID" ]]; then
  groupmod -g "$PGID" i2psvc
fi

if [[ "$PUID" != "" && "$SUID" != "$PUID" ]]; then
  usermod -u "$PUID" -g "$PGID" i2psvc
fi

if [[ -z "$MEM_MAX" ]]; then
  MEM_MAX="128"
fi

sed -i "s/^wrapper\.java\.maxmemory=[0-9]*$/wrapper.java.maxmemory=${MEM_MAX}/g" /etc/i2p/wrapper.config

# Ensure user rights
mkdir -p /var/lib/i2p/i2p-config
chown -R i2psvc:$PGID /var/lib/i2p
chmod -R u+rwx /var/lib/i2p

exec gosu i2psvc /usr/bin/i2prouter console
