#!/bin/bash

E_MAUVAISARGS=65
E_NOTROOT=126

ROOT_UID=0

COUNTRY=FR
STATE=France
ORGANIZATION=Lmarin

OUT_DIR=/opt/domains/config/ssl/csr

if [ $# -ne 2 ]
then
  echo "Usage: `basename $0` virtualHostName mailnotifier"
  exit $E_MAUVAISARGS
fi

if [ "$UID" -ne "$ROOT_UID" ]
then
  echo "You mut be root to run this script" 1>&2
  exit E_NOTROOT
fi

virtualHostName=$1
mailnotifier=$2

openssl req -new -key /opt/domains/config/ssl/private.pem -out $OUT_DIR/$virtualHostName.csr <<EOF
FR
France
Paris
Lmarin
Lmarin
$virtualHostName
$mailnotifier


EOF

CST=$(cat $OUT_DIR/$virtualHostName.csr)
mail -s "Creation following CSR for $virtualHostName" $mailnotifier <<EOM
Request sign following csr by cacert for domain $virtualHostName

$CST

EOM

exit 0
