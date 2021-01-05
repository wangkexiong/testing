FROM ubuntu:focal as BASE

ARG WEBSTORM_BUILD=2020.3.1
ARG NVM_VERSION=0.37.2

RUN apt-get update && \
    apt-get install -y curl git

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash && \
    mkdir -p /move && mv /root/.nvm /root/.bashrc /move

RUN mkdir -p /opt/jetbrain && cd /opt/jetbrain && \
    PKG_SOURCE=https://download.jetbrains.com/webstorm/WebStorm-${WEBSTORM_BUILD}.tar.gz && \
    curl -fsSL $PKG_SOURCE -o /opt/jetbrain/installer.tgz && \
    tar --strip-components=1 -xzf installer.tgz && \
    rm -rf installer.tgz

COPY entrypoint.sh /opt

FROM ubuntu:focal
LABEL maintainer=wangkexiong

RUN apt-get update && \
    apt-get install -y x11-utils rsync && \
    apt-get autoremove -y && apt-get clean all -y && \
    rm -rf /var/lib/apt/lists/* /var/log/apt/*

COPY --from=BASE /move /root
COPY --from=BASE /opt /opt