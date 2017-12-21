#!/bin/bash

if ! [[ "$1" =~ ^(\./)?wordpress.* ]];
then
	echo "Argument does not start with '(\./)?wordpress'. Aborting ..."
	exit 1
fi

if [ ! -d "$1" ];
then
	echo "Argument is either not a directory or does not exist. Aborting ..."
fi

rm --force --recursive \
	./"$1"/license.txt \
	./"$1"/readme.html \
	./"$1"/wp-config-sample.php \
	./"$1"/wp-content

