#!/bin/bash
#
# BibTeX Kreuvfizer
# Style BibTeX bibliography files the Kreuvfian way
# Author: Steven 'Kreuvf' Koenig
# Created: 2015-08-20
# Licence: Public domain
#
# Uses GNU extensions of sed.
#
# * Convert newlines to Unix/Linux newlines
# * Remove UTF-8 Byte-Order Mark everywhere
# * Remove escaped curly braces
# * Use curly braces instead of quotes
# * Remove whitespace after opening curly brace
# * Remove whitespace before closing curly brace
# * Use one and only one tab to indent entry fields
# * Use small letters for entry types and fields
# * Use one and only one space as whitespace between entry field and equality sign
# * Use one and only one space as whitespace between equality sign and curly brace
# * Use one and only one dash for page ranges, no whitespace
# * Replace entry field "journal" with "journaltitle"
# * Remove empty entry fields
# * Remove trailing whitespace at the end of the line, before the final comma
# * Remove whitespace at the end of the line (after "}")
# * End every entry field value with a comma (= comma after "}")
# * In doi field remove URL to DOI resolver and replace with DOI
#
# Future plans (the tricky non-oneliner ones ;D)
# * Remove url field, if it is a link to the DOI resolver if DOI is given and the same
# * Replace url field with URL to DOI resolver with doi field containing the DOI
# * For article entry fields use sequence:
#  * author, title, year, journaltitle, volume, number, pages, doi/url, note
#  * everything else afterwards in alphabetical order
# * Expand page ranges to full numbers ("4256-68" becomes "4256-4268")
# * Make page range expansion work with weird numbers as well (like "S368-70")
# * Put names into unambiguous order ("L_name, F_name and L_name, F_name"
# * Understand escaped special characters and work around those (instead of killing them)

dos2unix --quiet "$1"
sed -i -r \
-e 's|^\xEF\xBB\xBF||' \
-e 's|\\\{||g' \
-e 's|\\\}||g' \
-e 's|^([^"]+)"([^"]*)"(.*)$|\1{\2}\3|' \
-e 's|\{[[:space:]]*|{|' \
-e 's|[[:space:]]*\}|}|' \
-e 's|^([^@}\t].*)$|\t\1|g' \
-e 's|^([^=]*)=|\L\1=|g' \
-e 's|^\t([^[:space:]]+)[[:space:]]*=|\t\1 =|g' \
-e 's|=[[:space:]]*|= |' \
-e 's|pages = \{([^-[:space:]]+)-[-[:space:]]*([^-[:space:]]+)\}|pages = {\1-\2}|' \
-e 's|journal = \{|journaltitle = {|' \
-e '/\{\}/ d' \
-e 's|[[:space:]]*,[[:space:]]*$|,|' \
-e 's|^(.*\})[[:space:]]*$|\1|' \
-e 's|^(\t.*)\}$|\1},|' \
-e '/\tdoi = \{/ s|https?://dx.doi.org/||' "$1"

