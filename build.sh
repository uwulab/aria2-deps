#!/bin/bash

set -x

UNAME=$(uname -s)
case "${UNAME}" in
    Linux*)     NPROC=$(nproc);;
    Darwin*)    NPROC=$(sysctl -n hw.ncpu);;
    *)          NPROC=2;;
esac

ROOT_DIR="$(pwd)"

LIBXML2_VERSION=2.11.5
OPENSSL_VERSION=3.1.3
LIBSSH2_VERSION=1.11.0
LIBCARES2_VERSION=1.20.1
LIBCARES2_VERSION_UNDERSCORE=${LIBCARES2_VERSION//./_}
SQLITE3_VERSION=3430200

mkdir -p "tarballs"
mkdir -p "src"
mkdir -p "deps"

# build libxml2
if [ ! -f "tarballs/libxml2-v${LIBXML2_VERSION}.tar.gz" ]; then
    curl -fSL "https://github.com/GNOME/libxml2/archive/refs/tags/v${LIBXML2_VERSION}.tar.gz" -o "tarballs/libxml2-v${LIBXML2_VERSION}.tar.gz" ;
fi
tar -xzf "tarballs/libxml2-v${LIBXML2_VERSION}.tar.gz" -C src
cd "src/libxml2-${LIBXML2_VERSION}"
cmake -S . -B libxml2-build \
    -D BUILD_SHARED_LIBS=OFF \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D LIBXML2_WITH_ICONV=OFF \
    -D LIBXML2_WITH_LZMA=OFF \
    -D LIBXML2_WITH_PYTHON=OFF \
    -D LIBXML2_WITH_ZLIB=OFF
cd libxml2-build && \
    make -j${NPROC} && \
    make DESTDIR="${ROOT_DIR}/deps" install
cd "${ROOT_DIR}"

# build libc-ares2
if [ ! -f "tarballs/libc-ares-${LIBCARES2_VERSION}.tar.gz" ]; then
    curl -fSL "https://github.com/c-ares/c-ares/releases/download/cares-${LIBCARES2_VERSION_UNDERSCORE}/c-ares-${LIBCARES2_VERSION}.tar.gz" -o "tarballs/libc-ares-${LIBCARES2_VERSION}.tar.gz" ;
fi
tar -xzf "tarballs/libc-ares-${LIBCARES2_VERSION}.tar.gz" -C src
cd "src/c-ares-${LIBCARES2_VERSION}"
./configure --prefix=/usr/local --enable-shared=no --enable-static=yes
make -j${NPROC} && \
    make DESTDIR="${ROOT_DIR}/deps" install
cd "${ROOT_DIR}"

# build openssl
if [ ! -f "tarballs/openssl-${OPENSSL_VERSION}.tar.gz" ]; then
    curl -fSL "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -o "tarballs/openssl-${OPENSSL_VERSION}.tar.gz"
fi
tar -xzf "tarballs/openssl-${OPENSSL_VERSION}.tar.gz" -C src
cd "src/openssl-${OPENSSL_VERSION}"
./config --prefix=/usr/local no-shared
make -j${NPROC}
make DESTDIR="${ROOT_DIR}/deps" install_sw
cd "${ROOT_DIR}"

# build libssh
if [ ! -f "tarballs/libssh2-${LIBSSH2_VERSION}.tar.gz" ]; then
    curl -fSL "https://libssh2.org/download/libssh2-${LIBSSH2_VERSION}.tar.gz" -o "tarballs/libssh2-${LIBSSH2_VERSION}.tar.gz"
fi
tar -xzf "tarballs/libssh2-${LIBSSH2_VERSION}.tar.gz" -C src
cd "libssh2-${LIBSSH2_VERSION}"
mkdir build & cd build
cmake .. -DBUILD_SHARED_LIBS=OFF -DCRYPTO_BACKEND=OpenSSL
make -j${NPROC}
make DESTDIR="${ROOT_DIR}/deps" install
cd "${ROOT_DIR}"

# build sqlite3
if [ ! -f "tarballs/sqlite-autoconf-${SQLITE3_VERSION}.tar.gz" ]; then
    curl -fSL "https://www.sqlite.org/2023/sqlite-autoconf-${SQLITE3_VERSION}.tar.gz" -o "tarballs/sqlite-autoconf-${SQLITE3_VERSION}.tar.gz"
fi
tar -xzf "sqlite-autoconf-${SQLITE3_VERSION}.tar.gz" -C src
cd "src/sqlite-autoconf-${SQLITE3_VERSION}"
./configure --enable-shared=no
make -j${NPROC}
make DESTDIR="${ROOT_DIR}/deps" install
cd "${ROOT_DIR}"
