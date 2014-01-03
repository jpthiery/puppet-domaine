#!/bin/bash
if grep -q $1 $2
then
	exit 1
else 
	exit 0
fi	