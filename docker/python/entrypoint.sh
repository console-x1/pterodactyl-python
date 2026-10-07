#!/bin/bash

cd /home/container || exit 1

VENV_DIR="/home/container/.venv"
REQUIREMENTS_FILE="${REQUIREMENTS_FILE:-requirements.txt}"

echo "[Python] Python: $(python --version 2>&1)"
echo "[Python] pip: $(pip --version | awk '{print $2}')"

if [ -x "${VENV_DIR}/bin/python" ]; then
    SYS_VER=$(python -c 'import sys; print("%d.%d" % sys.version_info[:2])')
    VENV_VER=$("${VENV_DIR}/bin/python" -c 'import sys; print("%d.%d" % sys.version_info[:2])' 2>/dev/null)
    if [ "${SYS_VER}" != "${VENV_VER}" ]; then
        echo "[Python] Version Python changed (${VENV_VER} -> ${SYS_VER}), recreating venv..."
        rm -rf "${VENV_DIR}"
    fi
fi

if [ ! -x "${VENV_DIR}/bin/python" ]; then
    echo "[Python] Creation of venv..."
    python -m venv "${VENV_DIR}" || { echo "[Python] ERROR: Failed to create venv."; exit 1; }
    FRESH_VENV=1
fi

export VIRTUAL_ENV="${VENV_DIR}"
export PATH="${VENV_DIR}/bin:${PATH}"


if [ -f uv.lock ] && [ -f pyproject.toml ]; then
    echo "[Python] uv.lock detected: uv sync --frozen"
    uv sync --frozen || echo "[Python] WARNING: uv sync failed."
elif [ -f "${REQUIREMENTS_FILE}" ]; then
    echo "[Python] Installation from ${REQUIREMENTS_FILE}..."
    uv pip install -r "${REQUIREMENTS_FILE}" || echo "[Python] WARNING: installation failed."
elif [ -f pyproject.toml ]; then
    echo "[Python] pyproject.toml found: installing..."
    uv pip install . || echo "[Python] WARNING: installation failed."
else
    echo "[Python] No dependencies file found."
fi

if [ -n "${PY_PACKAGES}" ]; then
    echo "[Python] Additional packages: ${PY_PACKAGES}"
    uv pip install ${PY_PACKAGES} || echo "[Python] WARNING: installation of additional packages failed."
fi

if [ -n "${STARTUP}" ]; then
    RAW_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
    eval "MODIFIED_STARTUP=\"${RAW_STARTUP}\""

    echo "[Python] Starting: ${MODIFIED_STARTUP}"
    exec bash -c "${MODIFIED_STARTUP}"
fi

echo "[Python] No STARTUP command provided."
exec bash
