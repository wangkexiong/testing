FROM centos:7

RUN yum install -y git gcc \
    && curl -sSf https://sh.rustup.rs | sh -s -- -y \
    && git clone --recurse-submodules https://github.com/denoland/deno.git \
    && yum clean all \
    && rm -rf /var/cache/yum
