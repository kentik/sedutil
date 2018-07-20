#!/bin/bash

WORKSPACE=`pwd`

WORKDIRS="${WORKSPACE}/LinuxPBA ${WORKSPACE}/linux/CLI"
VERSION="Release_x86_64"
OPAL_UNIT=systemd-opal.service
EXEDIR=/usr/sbin
USR_SYSTEMD=/etc/systemd/service
PKGDIR=debian

set -ex

#FIXME Cleanup
for WRKDIR in $WORKDIRS
do
	( cd $WRKDIR; make CONF=${VERSION} clean ) || /bin/true
done

rm -rf ${PKGDIR} || /bin/true
mkdir -p ${PKGDIR}/${EXEDIR} || /bin/true
mkdir -p ${PKGDIR}/${USR_SYSTEMD} || /bin/true

for DIR in $WORKDIRS
do
  ( cd $DIR ; make CONF=${VERSION} clean ; make CONF=${VERSION} ) 2>&1 | tee logfile.txt
done

for DIR in $WORKDIRS
do
  cp ${DIR}/dist/${VERSION}/GNU-Linux/* ${PKGDIR}/${EXEDIR}
done

cp Contrib/${OPAL_UNIT} ${PKGDIR}/${USR_SYSTEMD}
chmod 0664 ${PKGDIR}/${USR_SYSTEMD}/${OPAL_UNIT}

dpkg-deb --build . .