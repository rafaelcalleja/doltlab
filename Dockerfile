FROM alpine:3.16
ARG VERSION

ENV DONWLOAD_URL "https://github.com/dolthub/dolt/releases/download/$VERSION/install.sh"

RUN apk add --no-cache bash curl \
    && curl -L "${DONWLOAD_URL}" | bash \
    && mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

ENTRYPOINT ["/usr/local/bin/dolt"]
