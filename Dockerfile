# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/openstack-venv-builder:2023.2@sha256:ebdb136fd832ddae76e745cdacc81ef188ac885a4ff5a8d217bcb7cfd8d33e27 AS build
RUN --mount=type=bind,from=manila,source=/,target=/src/manila,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/manila
EOF

FROM ghcr.io/vexxhost/python-base:2023.2@sha256:a79e8c32dff2f2eba0ed76b8897ed5bb7bd45852d58a4a119620eb968e1693f2
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
