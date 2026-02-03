# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later
# Atmosphere-Rebuild-Time: 2024-06-25T22:49:25Z

FROM ghcr.io/vexxhost/openstack-venv-builder:main@sha256:0bf034786931ad524be9eb4b202c6289ecfe73ae9a2a33f5496743742ea6f628 AS build
RUN --mount=type=bind,from=manila,source=/,target=/src/manila,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/manila
EOF

FROM ghcr.io/vexxhost/python-base:main@sha256:eeb4be14356f46a98d19a0a0f39602e4d9a8c4d993f0ab6621b6c402f70caedc
RUN \
    groupadd -g 42424 manila && \
    useradd -u 42424 -g 42424 -M -d /var/lib/manila -s /usr/sbin/nologin -c "Manila User" manila && \
    mkdir -p /etc/manila /var/log/manila /var/lib/manila /var/cache/manila && \
    chown -Rv manila:manila /etc/manila /var/log/manila /var/lib/manila /var/cache/manila
RUN <<EOF bash -xe
apt-get update -qq
apt-get install -qq -y --no-install-recommends \
    iproute2 openvswitch-switch python3-ceph-argparse python3-rados
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF
COPY --from=build --link /var/lib/openstack /var/lib/openstack
