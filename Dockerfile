# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/openstack-venv-builder:2023.2@sha256:738d0547cc0b265a1d62fd4196e3116cc2598848aa45a087345c67c7606a4288 AS build
RUN --mount=type=bind,from=manila,source=/,target=/src/manila,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/manila
EOF

FROM ghcr.io/vexxhost/python-base:2023.2@sha256:6711ea0e2cd26380ae5b28ca964d87eb0629314efb1da96534903fe4afa2e105
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
