FROM ubuntu:focal as BASE

ARG NVM_VERSION=0.37.2
ARG NODEJS_VERSION=12.20.0

COPY source /root/blog/source
COPY _config.yml _config.next.yml entrypoint.sh gulpfile.js package.json /root/blog/

WORKDIR /root/blog
RUN apt-get update -y && \
    apt-get install -y autoconf automake gcc make curl git && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh" && \
    cd /root/blog && \
    chmod +x entrypoint.sh && \
    nvm install ${NODEJS_VERSION} && \
    npm install yarn -g && yarn && \
    rm -rf yarn.lock && nvm cache clear && \
    mkdir -p /move && mv /root/.nvm /root/.bashrc /move

FROM ubuntu:focal
LABEL maintainer=wangkexiong

COPY --from=BASE /root/blog /root/blog
COPY --from=BASE /move /root/

WORKDIR /root/blog
RUN apt-get update -y && \
    apt-get install -y git && \
    apt-get clean all -y && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /var/log/apt

ENTRYPOINT [ "/root/blog/entrypoint.sh" ]
