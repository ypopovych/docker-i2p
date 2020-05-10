FROM ubuntu:18.04

LABEL maintainer="Yehor Popovych <popovych.yegor@gmail.com>"

ENV I2P_VERSION="0.9.45-1ubuntu1"
ENV I2P_DIR=/usr/share/i2p
ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

ADD entrypoint.sh /entrypoint.sh

# installing packages. Clearing caches
RUN apt-get -y update \
  && apt-get -y install apt-transport-https wget gnupg gosu locales procps \
  && echo "deb https://deb.i2p2.de/ bionic main" > /etc/apt/sources.list.d/i2p.list \
  && wget -O - https://geti2p.net/_static/i2p-debian-repo.key.asc | apt-key add - \
  && apt-get -y update \
  && apt-get -y install i2p="${I2P_VERSION}" i2p-keyring \
  && apt-get clean \
  && rm -rf /var/lib/i2p \
  && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/* \
  && echo "RUN_AS_USER=i2psvc" >> /etc/default/i2p \
  && sed -i 's/.*\(en_US\.UTF-8\)/\1/' /etc/locale.gen \
  && /usr/sbin/locale-gen \
  && /usr/sbin/update-locale LANG=${LANG} LANGUAGE=${LANGUAGE} \
  && sed -i 's/127\.0\.0\.1/0.0.0.0/g' ${I2P_DIR}/i2ptunnel.config \
  && sed -i 's/::1,127\.0\.0\.1/0.0.0.0/g' ${I2P_DIR}/clients.config \
  && printf "i2cp.tcp.bindAllInterfaces=true\n" >> ${I2P_DIR}/router.config \
  && printf "i2np.ipv4.firewalled=true\ni2np.ntcp.ipv6=false\n" >> ${I2P_DIR}/router.config \
  && printf "i2np.udp.ipv6=false\ni2np.upnp.enable=false\n" >> ${I2P_DIR}/router.config \
  && chmod a+x /entrypoint.sh

VOLUME /var/lib/i2p

EXPOSE 4444 4445 6668 7654 7656 7657 7658 7659 7660 8998 15000-20000

ENTRYPOINT [ "/entrypoint.sh" ]