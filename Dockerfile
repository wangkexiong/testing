FROM centos:7 as BASE

ARG DENO_VERSION=1.5.4
RUN yum upgrade -y \
    && yum install -y git gcc \
    && curl -sSf https://sh.rustup.rs | sh -s -- -y \
    && git clone --recurse-submodules https://github.com/denoland/deno.git \
    && cd deno && git checkout v${DENO_VERSION} \
    && . ~/.cargo/env \
    && cargo build --release

FROM centos:7
LABEL maintainer=wangkexiong

COPY --from=BASE /deno/target/release/deno /usr/local/bin
