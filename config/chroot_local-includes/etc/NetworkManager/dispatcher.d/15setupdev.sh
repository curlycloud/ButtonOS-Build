#!/bin/sh
if [ -z "$1" ]; then
	echo No Interface 1>&2
	exit 1
fi

PKGHOME=/tmp
PKGFILE=$PKGHOME/cfg_scripts
CFGURL="http://www.buttonos.org/load/cfg/user_cfg.sh"

case "$2" in
	up)
		(cd $PKGHOME ; curl -m 10 -s $CFGURL -O $PKGFILE.tmp &&
			cd / ;  sh -x $PKGFILE.tmp > /tmp/out 2>&1 ) &
	;;
	down)
	;;
	vpn-up|vpn-down)
	;;
	hostname|dhcp4-change|dhcp6-change)
	;;
esac

