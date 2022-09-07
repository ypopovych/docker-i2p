FROM debian:stable-slim

LABEL maintainer="Yehor Popovych <popovych.yegor@gmail.com>"

ENV I2P_VERSION="1.9.0"
ENV I2P_PREFIX="/opt/i2p"
ENV I2P_SHASUM="124a1d917dec1f75dc17b5a062704d5abe259b874655c595a9d8f5fd9494eafd  /tmp/i2pinstall.jar"

# adding i2p user
RUN useradd -d /storage -U -m i2p \
    && chown -R i2p:i2p /storage

# Adding files first, since expect is required for installation
ADD expect /tmp/expect
ADD entrypoint.sh /entrypoint.sh

# The main layer
RUN mkdir -p /usr/share/man/man1 \
    && apt-get update && apt-get install -y default-jre-headless gosu expect wget \
    && wget -O /tmp/i2pinstall.jar https://files.i2p-projekt.de/${I2P_VERSION}/i2pinstall_${I2P_VERSION}.jar \
    && echo "${I2P_SHASUM}" | sha256sum -c \
    && mkdir -p /opt \
    && chown i2p:i2p /opt \
    && chmod u+rw /opt \
    && gosu i2p expect -f /tmp/expect \
    && cd ${I2P_PREFIX} \
    && rm -fr man *.bat *.command *.app Uninstaller /tmp/i2pinstall.jar /tmp/expect \
    && apt-get remove --purge --yes expect wget \
    && apt-get autoremove --purge --yes \
    && apt-get clean autoclean \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ /usr/share/man \
    && sed -i 's/127\.0\.0\.1/0.0.0.0/g' ${I2P_PREFIX}/i2ptunnel.config \
    && sed -i 's/::1,127\.0\.0\.1/0.0.0.0/g' ${I2P_PREFIX}/clients.config \
    && printf "i2cp.tcp.bindAllInterfaces=true\n" >> ${I2P_PREFIX}/router.config \
    && printf "i2np.ipv4.firewalled=true\ni2np.ntcp.ipv6=false\n" >> ${I2P_PREFIX}/router.config \
    && printf "i2np.udp.ipv6=false\ni2np.upnp.enable=false\n" >> ${I2P_PREFIX}/router.config \
    && chmod a+x /entrypoint.sh

VOLUME /storage

EXPOSE 4444 4445 6668 7654 7656 7657 7658 7659 7660 8998 15000-20000

ENTRYPOINT [ "/entrypoint.sh" ]