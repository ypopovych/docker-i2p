FROM alpine:3

LABEL maintainer="Yehor Popovych <popovych.yegor@gmail.com>"

ENV I2P_VERSION="0.9.46"
ENV I2P_PREFIX="/opt/i2p"
ENV I2P_SHASUM="bc8ec63e1df5eba7b22c57a143ff177a1fb208f793f07ecf249f3589029def1e  /tmp/i2pinstall.jar"

# adding i2p user
RUN mkdir /storage \
    && adduser -g i2p -h /storage --disabled-password i2p \
    && chown -R i2p:i2p /storage

# Adding files first, since expect is required for installation
ADD expect /tmp/expect
ADD entrypoint.sh /entrypoint.sh

# The main layer
RUN apk --no-cache add openssl openjdk8-jre fontconfig ttf-dejavu gcompat mailcap shadow su-exec expect \
    && mkdir /lib64 && cd /lib64 && ln -s /lib/ld-linux-* \
    && wget -O /tmp/i2pinstall.jar https://download.i2p2.de/releases/${I2P_VERSION}/i2pinstall_${I2P_VERSION}.jar \
    && echo "${I2P_SHASUM}" | sha256sum -c \
    && mkdir -p /opt \
    && chown i2p:i2p /opt \
    && chmod u+rw /opt \
    && su-exec i2p expect -f /tmp/expect \
    && cd ${I2P_PREFIX} \
    && rm -fr man *.bat *.command *.app Uninstaller /tmp/i2pinstall.jar /tmp/expect \
    && apk --purge del expect tcl openssl \
    && sed -i 's/127\.0\.0\.1/0.0.0.0/g' ${I2P_PREFIX}/i2ptunnel.config \
    && sed -i 's/::1,127\.0\.0\.1/0.0.0.0/g' ${I2P_PREFIX}/clients.config \
    && printf "i2cp.tcp.bindAllInterfaces=true\n" >> ${I2P_PREFIX}/router.config \
    && printf "i2np.ipv4.firewalled=true\ni2np.ntcp.ipv6=false\n" >> ${I2P_PREFIX}/router.config \
    && printf "i2np.udp.ipv6=false\ni2np.upnp.enable=false\n" >> ${I2P_PREFIX}/router.config \
    && chmod a+x /entrypoint.sh

VOLUME /storage

EXPOSE 4444 4445 6668 7654 7656 7657 7658 7659 7660 8998 15000-20000

ENTRYPOINT [ "/entrypoint.sh" ]