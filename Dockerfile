FROM ubuntu:focal
LABEL maintainer=wangkexiong

ARG WEBSTORM_BUILD=2020.3.1

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get autoremove -y && apt-get clean all -y && \
    rm -rf /var/lib/apt/lists/* /var/log/apt/*

RUN mkdir -p /opt/jetbrain && cd /opt/jetbrain && \
    PKG_SOURCE=https://download.jetbrains.com/webstorm/WebStorm-${WEBSTORM_BUILD}.tar.gz && \
    curl -fsSL $PKG_SOURCE -o /opt/jetbrain/installer.tgz && \
    tar --strip-components=1 -xzf installer.tgz && \
    rm -rf installer.tgz
