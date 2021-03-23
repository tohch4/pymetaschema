ARG CYTHON_VERSION=0.29.22
ARG SAXONC_BUILD_DIR="/usr/local/src/saxon"
ARG SAXONC_DL_DIR="/tmp"
ARG SAXONC_TARGET_DIR="/usr/local/lib/python3.9"
ARG SAXONC_TARGET_DEPS="{saxonc.cpython-39-x86_64-linux-gnu.so,nodekind.py}"
ARG SAXONC_VERSION="libsaxon-HEC-setup64-v1.2.1"
ARG SAXONC_URL="https://www.saxonica.com/saxon-c/${SAXONC_VERSION}.zip"

FROM python:3.9.2-buster as builder

ARG CYTHON_VERSION
ARG SAXONC_BUILD_DIR
ARG SAXONC_DL_DIR
ARG SAXONC_TARGET_DIR
ARG SAXONC_VERSION
ARG SAXONC_URL

RUN curl -L -o "${SAXONC_DL_DIR}/saxonc.zip" "${SAXONC_URL}" && \
    mkdir -p "${SAXONC_BUILD_DIR}" && \
    unzip "${SAXONC_DL_DIR}/saxonc.zip" -d ${SAXONC_DL_DIR} && \
    rm -f "${SAXONC_DL_DIR}/saxonc.zip" && \
    ${SAXONC_DL_DIR}/${SAXONC_VERSION} -batch -dest "${SAXONC_BUILD_DIR}" && \
    pip3 install Cython==${CYTHON_VERSION} && \
    ( \
        cd "${SAXONC_BUILD_DIR}/Saxon.C.API/python-saxon" && \
        python3 saxon-setup.py build_ext -if \
    )

FROM python:3.9.2-buster

ARG SAXONC_BUILD_DIR
ARG SAXONC_TARGET_DIR
ARG SAXONC_TARGET_LIB

RUN mkdir -p "${SAXONC_TARGET_DIR}"
COPY --from=builder "${SAXONC_BUILD_DIR}/Saxon.C.API/python-saxon/${SAXONC_TARGET_DEPS}" "${SAXONC_TARGET_DIR}"