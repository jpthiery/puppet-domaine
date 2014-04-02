#!/bin/sh
#
#	Fetch arhive from url $1
#	un archive it
#	copy result to destination $2
#	Usage : fetcharchive http://archive.org/download.archive-1.5.6.zip /opt/domain/truc/
#

ERR_INVALID_ARG=126
CACHEDIR=/opt/apps/cache

if [ $# -ne 2 ]; then
	
	echo invalid arguments
	echo Usage : $0 [URL] [DESTINATION]
		
	exit $ERR_INVALID_ARG
fi

URL=$1
DESTINATION=$2

TMP_FILE_NAME=`basename $DESTINATION`
TMP_FILE=$CACHEDIR/$TMP_FILE_NAME

if [ ! -f $DESTINATION ]; then
	
	mkdir -p $CACHEDIR	
	
	echo "Cache file $TMP_FILE"
	
	if [ -f $TMP_FILE ]; then
		cp $TMP_FILE $DESTINATION
		exit $?		
	fi
	
	echo "Downloading from $URL"
	curl -L $URL -o $TMP_FILE
	if [ $? -ne 0 ]; then
		echo "Unable to download archive from $URL"
		rm -f $TMP_FILE
		exit 1
	fi
	
	cp $TMP_FILE $DESTINATION
	exit $?

fi
