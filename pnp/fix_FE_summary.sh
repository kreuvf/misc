#!/bin/bash

# Author(s): Steven "Kreuvf" Koenig
# Licence(s):
#	Public Domain/Creative Commons Zero
#	https://creativecommons.org/publicdomain/zero/1.0/
#

if [ ! -f "$1" ]; then
	echo "\"$1\" not found. Exiting ..."
	exit
fi

# Heuristic to find out whether this script was already used on the file
MONTH=`head --lines=1 "$1" | grep -o -E '((Jan|Febr)uar|März|April|Mai|Ju[nl]i|August|(Sept|Nov|Dez)ember|Oktober)' | wc -c`
if [ $MONTH -gt 0 ]; then
	echo "Looks like this script was already used on that file. Exiting ..."
	exit
fi

# Convert to UTF-8
iconv -f ISO-8859-15 -t UTF-8 -o "$1".tmp "$1"

# Convert to sensible newlines
dos2unix "$1".tmp

# Line 1: Convert DD.MM.YYYY date to DD. Month YYYY date (without leading zero day)
sed -r -i \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)0?1\.([0-9]+)/\1 Januar \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)0?2\.([0-9]+)/\1 Februar \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)0?3\.([0-9]+)/\1 März \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)0?4\.([0-9]+)/\1 April \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)0?5\.([0-9]+)/\1 Mai \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)0?6\.([0-9]+)/\1 Juni \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)0?7\.([0-9]+)/\1 Juli \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)0?8\.([0-9]+)/\1 August \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)0?9\.([0-9]+)/\1 September \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)10\.([0-9]+)/\1 Oktober \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)11\.([0-9]+)/\1 November \2/' \
	-e '1,1s/(Zusammenfassung vom [0-9]{1,2}\.)12\.([0-9]+)/\1 Dezember \2/' \
	-e '1,1s/(Zusammenfassung vom )(0([0-9])|([123][0-9]))(\..*)$/\1\3\4\5/' \
	"$1".tmp

# Line 2: Adjust number of equal signs to line length of line 1
HEADINGLENGTH=`sed -r -e '1q;d' "$1".tmp | wc -c`
HEADINGLINE=`seq -s= $HEADINGLENGTH | tr -d '[:digit:]'`
sed -r -i \
	-e "2,2s/.*/$HEADINGLINE/" \
	"$1".tmp

# Line 3: Add real title derived from filename
sed -r -i -e '3,3s/(.*)/\n\n\1/' "$1".tmp
## Extract title
TITLE=`echo "$1" | tr "_" " " | sed -r -e 's/^.{8,8} (.*)\.txt$/\1/'`
## Input title
sed -r -i -e "3,3s/.*/$TITLE/" "$1".tmp
## Add single dash underline
HEADINGLENGTH=`sed -r -e '3q;d' "$1".tmp | wc -c`
HEADINGLINE=`seq -s- $HEADINGLENGTH | tr -d '[:digit:]'`
sed -r -i \
	-e "4,4s/.*/$HEADINGLINE/" \
	"$1".tmp

# Todo: Remove consecutive empty newlines (except for one)

# Fix spelling and punctuation issues
sed -r -i \
	-e 's/([^& \t])\&([^& \t])/\1 \& \2/g' \
	-e 's/^(.*)[ \t]+$/\1/' \
	-e 's//'"'"'/g' \
	-e 's/([0-9]\.)(PRA|RON|EFF|TRA|BOR|HES|FIR|TSA|PHE|PER|ING|RAH|NL|Praios|Rondra|Efferd|Travia|Boron|Hesinde|Firun|Tsa|Phex|Peraine|Ingerimm|Rahja|Tage? ohne Namen|Namenloser? Tage?)/\1 \2/g' \
	-e 's/([0-9])(Sommer)/\1 \2/g' \
	-e 's/\b([0-9]+)([DSHK])\b/\1 \2/g' \
	-e 's/Abogast/Arbogast/g' \
	-e 's/\bAnatomi\b/Anatomie/g' \
	-e 's/beiss(t|en)/beiß\1/g' \
	-e 's/\bCugon\b/Cugono/g' \
	-e 's/daß/dass/g' \
	-e 's/detaliert/detailliert/g' \
	-e 's/erkennbbar/erkennbar/g' \
	-e 's/Fakel/Fackel/g' \
	-e 's/Fluß/Fluss/g' \
	-e 's/Guppe/Gruppe/g' \
	-e 's/Ingere?im([^m])/Ingerimm\1/g' \
	-e 's/Invalsveste/Ingvalsfeste/g' \
	-e 's/Küraß/Kürass/g' \
	-e 's/kurschtelt/kruschtelt/g' \
	-e 's/Lohwangen/Lowangen/g' \
	-e 's/Nimue/Nimuan/g' \
	-e 's/Occulis Astralis/Oculus Astralis/g' \
	-e 's/Perraine/Peraine/g' \
	-e 's/Ri Stadtinneres/Richtung Stadtinneres/g' \
	-e 's/rumreich/ruhmreich/g' \
	-e 's/Schankmagt/Schankmagd/g' \
	-e 's/[Ss]chwarz \& [Rr]ot/Schwarz \& Rot/g' \
	-e 's/Tunier/Turnier/g' \
	-e 's/überbrüft/überprüft/g' \
	-e 's/unütz/unnütz/g' \
	-e 's/Volorion/Wolorion/g' \
	-e 's/Zsatempel/Tsatempel/g' \
	-e 's/Zunfhäuser/Zunfthäuser/g' \
	-e 's/zurüchtgewiesen/zurechtgewiesen/g' \
	"$1".tmp

# Remove trailing whitespace
sed -r -i -e 's/[ \t]+$//g' "$1".tmp

# Unabbreviate
sed -r -i \
	-e 's/bzw\./beziehungsweise/g' \
	-e 's/bzgl\./bezüglich/g' \
	-e 's/evtl\./eventuell/g' \
	-e 's/wg\./wegen/g' \
	"$1".tmp

# Replace input file
cat "$1".tmp > "$1"
rm "$1".tmp

