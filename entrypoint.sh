#!/bin/sh

SGID=`getent group i2p | cut -d: -f3`
SUID=`id -u i2p`

if [[ "$PGID" != "" && "$SGID" != "$PGID" ]]; then
  groupmod -g "$PGID" i2p
fi

if [[ "$PUID" != "" && "$SUID" != "$PUID" ]]; then
  usermod -u "$PUID" -g "$PGID" i2p
fi

if [[ -z "$MEM_MAX" ]]; then
  MEM_MAX="128"
fi

sed -i "s/^wrapper\.java\.maxmemory=[0-9]*$/wrapper.java.maxmemory=${MEM_MAX}/g" $I2P_PREFIX/wrapper.config

# Ensure user rights
chown -R i2p:$PGID /storage
chown -R i2p:$PGID $I2P_PREFIX
chmod -R u+rwx /storage
chmod -R u+rwx $I2P_PREFIX

exec su-exec i2p $I2P_PREFIX/i2psvc $I2P_PREFIX/wrapper.config wrapper.pidfile=/var/tmp/i2p.pid \
   wrapper.name=i2p \
   wrapper.displayname="I2P Service" \
   wrapper.statusfile=/var/tmp/i2p.status \
   wrapper.java.statusfile=/var/tmp/i2p.java.status \
   wrapper.logfile=
