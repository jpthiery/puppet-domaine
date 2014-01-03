#!/bin/bash
# Usage : createdomainemail <domaine.com>

if [ $# -neq  2 ]; then
	echo "Usage : createdomainemail <domaine.com> <user@mail.com>"
    exit 1
fi

VDOMINFO_CMD=/home/vpopmail/bin/vdominfo
VADDDOMAIN_CMD=/home/vpopmail/bin/vadddomain

DOMAINE=$1
TO=$2

if [ -z `$VDOMINFO_CMD $DOMAINE | grep "^domain: $DOAMINE\$" | uniq -c | awk {'print $1'}` ]; then
    ADDED=$($VADDDOMAIN_CMD -r10 $DOMAINE)
    ADDED_RET=$?
    if [ $ADDED_RET -eq 0 ]; then
        PASS=`echo $ADDED | awk '{print $3}'`
        mail -s "Creation of domaine $DOMAINE" $TO <<EOM
$DOMAINE mail had been created.
Postmaster password: $PASS
$QMAILADMINURL
EOM
	else
		exit $ADDED_RET
    fi
fi

exit 0
