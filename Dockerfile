# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:2024.1@sha256:82cc411d098c8a6a74752d3068a79f3d52b6cedb4c6c905ea9b84ba420c0340c AS build
RUN --mount=type=bind,from=manila,source=/,target=/src/manila,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/manila
EOF

FROM ghcr.io/vexxhost/python-base:2024.1@sha256:dc7e45276d41fb8b20d7fcd6358ec49ac9b00047fb46dc025b1827aa4cd54ad9
RUN \
    groupadd -g 42424 manila && \
    useradd -u 42424 -g 42424 -M -d /var/lib/manila -s /usr/sbin/nologin -c "Manila User" manila && \
    mkdir -p /etc/manila /var/log/manila /var/lib/manila /var/cache/manila && \
    chown -Rv manila:manila /etc/manila /var/log/manila /var/lib/manila /var/cache/manila
RUN <<EOF bash -xe
apt-get update -qq
apt-get install -qq -y --no-install-recommends \
    iproute2 openvswitch-switch
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF
COPY --from=build --link /var/lib/openstack /var/lib/openstack
