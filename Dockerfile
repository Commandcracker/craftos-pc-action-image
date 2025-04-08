FROM ubuntu:jammy AS base

RUN set -eux && \
    apt-get update

FROM base AS build

ADD https://github.com/MCJack123/craftos2-luajit.git /craftos2-luajit
WORKDIR /craftos2-luajit

RUN set -eux && \
    apt-get install -y --no-install-recommends build-essential && \
    make

FROM base AS runtime

RUN set -eux && \
    apt-get install -y --no-install-recommends gpg-agent software-properties-common && \
    add-apt-repository ppa:jackmacwindows/ppa && \
    apt-get update && \
    apt-get install -y --no-install-recommends libx11-dev craftos-pc craftos-pc-accelerated && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'pcm.!default {type plug slave.pcm "null"}' > /etc/asound.conf

COPY src/.settings /opt/craftos-pc-action/settings/.settings
COPY src/craftos-pc-tweaks/lua /opt/craftos-pc-action/craftos-pc-tweaks
COPY src/run.sh /opt/craftos-pc-action/run.sh
COPY --from=build /craftos2-luajit/src/libluajit-craftos.so /craftos2-luajit/src/

CMD ["bash", "/opt/craftos-pc-action/run.sh"]
