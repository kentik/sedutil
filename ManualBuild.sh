#!/bin/bash

set -euxo pipefail
WORKSPACE=$(pwd)

WORKDIRS=("${WORKSPACE}/LinuxPBA" "${WORKSPACE}/linux/CLI")
VERSION="Release_x86_64"
OPAL_UNIT=sed-opal.service
EXEDIR=/usr/sbin
MAN_PAGE=sedutil-cli.8
MAN_DIR=/usr/share/man/man8
USR_SYSTEMD=/etc/systemd/system
PKGDIR=${WORKSPACE}/output/

export LDFLAGS=-static

COMMIT=$(git rev-parse --short HEAD)

PKG_VERSION=$(git describe HEAD)
#FIXME Cleanup
for WRKDIR in "${WORKDIRS[@]}"; do
	make -j8 -C "$WRKDIR" CONF="${VERSION}" clean
done

sudo rm -rf "${PKGDIR}"

mkdir -p "${PKGDIR}"
mkdir -p "${PKGDIR}/${EXEDIR}"
mkdir -p "${PKGDIR}/${USR_SYSTEMD}"
mkdir -p "${PKGDIR}/${MAN_DIR}"

for DIR in "${WORKDIRS[@]}"; do
  ( make -j8 -C "$DIR" CONF="${VERSION}" clean ; make -j8 -C "$DIR" CONF="${VERSION}" ) 2>&1 | tee logfile.txt
done

for DIR in "${WORKDIRS[@]}"; do
  cp "${DIR}/dist/${VERSION}/GNU-Linux/"* "${PKGDIR}/${EXEDIR}"
done

cp docs/"${MAN_PAGE}" "${PKGDIR}/${MAN_DIR}"
gzip -9 "${PKGDIR}/${MAN_DIR}/${MAN_PAGE}"
cp "Contrib/${OPAL_UNIT}" "${PKGDIR}/${USR_SYSTEMD}"
chmod 0644 "${PKGDIR}/${USR_SYSTEMD}/${OPAL_UNIT}"

sudo find "${PKGDIR}" -execdir chown 0:0 '{}' +;

echo "Dir content"
ls -R "${PKGDIR}"
