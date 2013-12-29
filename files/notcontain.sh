#!/bin/bash
if grep -q $1 /etc/bind/named.conf.options
then
	exit 1
else 
	exit 0
fi	