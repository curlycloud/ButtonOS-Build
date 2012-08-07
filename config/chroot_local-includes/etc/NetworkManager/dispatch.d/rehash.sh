#!/bin/sh
echo $* >>/tmp/NM.out
#on up
CFGURL="http://www.buttonos.org/load/themes/lxde-cfg.tgz"
INSTFILE=/usr/share/lxde/defcfg.tgz

(cd /tmp ; curl -m 10 -s $CFGURL -O $PKGFILE.tmp &&
		ln -s $PKGFILE.tmp $PKGFILE ) &

