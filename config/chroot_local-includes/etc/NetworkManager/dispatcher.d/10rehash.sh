#!/bin/sh
if [ -z "$1" ]; then
	echo No Interface 1>&2
	exit 1
fi

PKGHOME=/tmp
PKGFILE=$PKGHOME/lxde-cfg.tgz
CFGURL="http://www.buttonos.org/load/themes/lxde-cfg.tgz"
INSTFILE=/usr/share/lxde/defcfg.tgz

case "$2" in
	up)
	(cd $PKGHOME ; curl -m 10 -s $CFGURL -O $PKGFILE.tmp &&
		cd / ;  tar -xzf $PKGFILE.tmp ) &
	;;
	down)
		( cd / ;  tar -xzf $INSTFILE ) &
	;;
	vpn-up|vpn-down)
	;;
	hostname|dhcp4-change|dhcp6-change)
	;;
esac

