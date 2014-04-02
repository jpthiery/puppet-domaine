#!/bin/sh

SRC_DIR=/opt/domains/src
CONFIG_DIR=/opt/domains/config

ROUNDCUBE_VERSION=0.7.2
ROUNDCUBE_URL=http://sourceforge.net/projects/roundcubemail/files/roundcubemail/$ROUNDCUBE_VERSION/roundcubemail-$ROUNDCUBE_VERSION.tar.gz/download

VPOPMAIL_DIR=/home/vpopmail

usage() {
cat << EOF
usage : $0 options
This script setup a new Ldap database.
OPTIONS :
  -h HELP
  -d domain to add like "lmarin.org"
  -a postmaster password
  -l webmail database login
  -p webmail database password
  -r webmail database root password
EOF
}

if [ $# = 0 ]; then
  usage
  exit 1;
fi

#if [ ! "$UID" eq 0 ]; then
#  echo "You must run this script with ROOT Rigths"
#  exit 1;
#fi

while getopts "h:d:a:l:p:r:" OPTION
do
case $OPTION in
         h)
             usage
             exit 1
             ;;
         d)
             DOMAIN=$OPTARG
             ;;
         a)
             POSTMASTER_PASS=$OPTARG
             ;;
         l)
             WEBMAIL_BDD_LOGIN=$OPTARG
             ;;
         p)
             WEBMAIL_BDD_PASSWD=$OPTARG
      ;;
         r)
             BDD_ROOT_PASSWD=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

#if [ "${$VPOPMAIL_DIR/bin/vdominfo $DOMAIN}" != "Invalid domain name" ]; then
#  $VPOPMAIL_DIR/bin/vadddomain $DOMAIN $POSTMASTER_PASS
#fi

WEBMAIL_BDD=$WEBMAIL_BDD_LOGIN.$DOMAIN

$CONFIG_DIR/sql/createSchemas -d $DOMAIN -u $WEBMAIL_BDD_LOGIN -p $WEBMAIL_BDD_PASSWD -r $BDD_ROOT_PASSWD

if [ ! -e $SRC_DIR/roundcubemail-$ROUNDCUBE_VERSION ]; then
  pushd $CONFIG_DIR
  curl -L -l $ROUNDCUBE_URL -o $SRC_DIR/roundcubemail-$ROUNDCUBE_VERSION.tar.gz
  chmod +rx $SRC_DIR/roundcubemail-$ROUNDCUBE_VERSION.tar.gz
  cd $SRC_DIR
  tar xzf roundcubemail-$ROUNDCUBE_VERSION.tar.gz >>/dev/null 2>&1
  ln -sf roundcubemail-$ROUNDCUBE_VERSION roundcubemail
  popd
fi

if [ ! -e /var/domains/$DOMAIN/webmail ]; then
  mkdir -p /var/domains/$DOMAIN/webmail
fi

cp -R $SRC_DIR/roundcubemail-$ROUNDCUBE_VERSION/* /var/domains/$DOMAIN/webmail

cat /var/domains/$DOMAIN/webmail/config/main.inc.php.dist | sed "s/\$rcmail_config['username_domain'] = '';/\$rcmail_config['username_domain'] = '$DOMAIN';/g" > /var/domains/$DOMAIN/webmail/config/main.inc.php
cat /var/domains/$DOMAIN/webmail/config/db.inc.php.dist | sed "s#mysql://roundcube:pass@localhost/roundcubemail#mysql://$WEBMAIL_BDD_LOGIN:$WEBMAIL_BDD_PASSWD@localhost/$WEBMAIL_BDD#g" > /var/domains/$DOMAIN/webmail/config/db.inc.php
echo "\$rcmail_config['enable_installer'] = true;" >> /var/domains/$DOMAIN/webmail/config/main.inc.php

echo "php_value suhosin.session.encrypt Off" >> /var/domains/$DOMAIN/webmail/.htaccess

chown -R root:www-data /var/domains/$DOMAIN/webmail/{temp,logs}
chmod 775 /var/domains/$DOMAIN/webmail/{temp,logs}

exit 0