FROM centos:7

RUN yum upgrade -y \
    && yum install -y git gcc \
    && yum clean packages \
    && curl -sSf https://sh.rustup.rs | sh -s -- -y \
    && git clone --recurse-submodules https://github.com/denoland/deno.git \
    && cd deno \
    && . ~/.cargo/env \
    && cargo build --release \
    && mkdir /output \
    && cp target/release/deno /output

