# SPDX-FileCopyrightText: © 2025 VEXXHOST, Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

FROM ghcr.io/vexxhost/openstack-venv-builder:2023.2@sha256:7cb895fe71a668ab1c85d4bbe1a51d5b7986fa9977a12a304fee2bb2b77a7276 AS build
RUN --mount=type=bind,from=manila,source=/,target=/src/manila,readwrite <<EOF bash -xe
uv pip install \
    --constraint /upper-constraints.txt \
        /src/manila
EOF

FROM ghcr.io/vexxhost/python-base:2023.2@sha256:591869f64281a7429de38650a659b029554d68ed15d919ea95a0990e7d402d8b
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
