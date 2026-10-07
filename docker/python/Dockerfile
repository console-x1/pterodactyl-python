# syntax=docker/dockerfile:1

ARG PYTHON_VERSION=3.12
ARG PYTHON_VARIANT=trixie

FROM python:${PYTHON_VERSION}-slim-${PYTHON_VARIANT}

LABEL org.opencontainers.image.title="Pterodactyl Python"
LABEL org.opencontainers.image.description="Production Python runtime for Pterodactyl"

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    UV_LINK_MODE=copy \
    UV_NO_PROGRESS=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        openssh-client \
        tini \
        wget \
        unzip \
        zip \
        file \
        jq \
        procps \
        netcat-openbsd \
        libffi-dev \
        libssl-dev \
        libjpeg-dev \
        zlib1g-dev \
        libpq-dev \
        libmariadb-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip setuptools wheel uv

RUN useradd -m -d /home/container -s /bin/bash container \
    && mkdir -p /home/container \
    && chown -R container:container /home/container

COPY docker/python/entrypoint.sh /entrypoint.sh

USER container
ENV USER=container \
    HOME=/home/container
WORKDIR /home/container

ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/bin/bash", "/entrypoint.sh"]
