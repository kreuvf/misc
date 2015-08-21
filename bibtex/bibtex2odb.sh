#!/bin/bash
#
# BibTeX to Bibliography Database from Open/Libre Office "Converter"
# "Convert" author names into nicer format to use with OO/LO bibliography
# Author: Steven 'Kreuvf' Koenig
# Created: 2015-08-21
# Licence: Public domain
#
# * Authors in author field must be separated by ";"
#
# Future plans (the tricky non-oneliner ones ;D)
# * none

sed -i -r \
-e '/author =/s| and |; |g' "$1"


