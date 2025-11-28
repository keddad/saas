FROM alpine:3.22.2 AS build

# Find those at https://ziglang.org/download/
ENV HOST=x86_64-linux
ENV ZIG_VERSION=0.15.2

# Used to identify downloader, set to something recognizable
ENV PROJECT=keddad_saas

RUN apk add tar xz minisign

RUN wget https://ziglang.org/download/community-mirrors.txt

RUN wget $(shuf -n 1 ./community-mirrors.txt)/zig-${HOST}-${ZIG_VERSION}.tar.xz?source=${PROJECT} -O zig.tar.xz
RUN wget $(shuf -n 1 ./community-mirrors.txt)/zig-${HOST}-${ZIG_VERSION}.tar.xz.minisig?source=${PROJECT} -O zig.tar.xz.minisig

# Public key from https://ziglang.org/download/
RUN minisign -Vm zig.tar.xz -x zig.tar.xz.minisig -P RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti+JO/wCYvhbAb/U

RUN tar -xf zig.tar.xz

RUN mkdir -p /opt/zig/

RUN cp -r zig-${HOST}-${ZIG_VERSION}/* /opt/zig/

RUN mkdir -p ~/build

WORKDIR /root/build

COPY build.zig build.zig.zon /root/build/

COPY src/ /root/build/src/

RUN /opt/zig/zig build -Doptimize=ReleaseSmall

FROM alpine:3.22.2

RUN mkdir -p /opt/saas

COPY --from=build /root/build/zig-out/bin/saas /opt/saas/saas

ENTRYPOINT [ "/opt/saas/saas" ]