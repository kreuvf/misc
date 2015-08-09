#!/bin/bash

# Author(s): Toshiki Ishii
# Initial publication: 2015-06-26
# http://chem.toshiki.de/2015/06/pdf-als-bild-rastern-und-wieder-zu-einer-pdf-datei-zusammenfuegen/
# Licence(s):
#	Creative Commons Attribution 4.0 International
#	http://creativecommons.org/licenses/by/4.0/
#	

# Get information on PDF
echo "Reading page information for $1"
mapfile -t pageinfo < <(identify -density 300 $1)
pagecount=${#pageinfo[@]}
echo "    -> $pagecount pages"

# Only continue if the PDF exists and contains pages
if [ $pagecount -gt 0 ]
then

# Make temporary directory
filename=$(cut -d'/' -f$(($(grep -o "/" <<< $1 | wc -l)+1)) <<< $1 | cut -d'.' -f1)
tmppath="/tmp/pngpdf/$filename/"
mkdir "/tmp/pngpdf/"
mkdir "$tmppath"

# Render pages as PNG
echo "Rendering PDF pages as PNG"
curr=1
files=""
while [ $curr -le $pagecount ]
do
	currpageinfo=(${pageinfo[$((curr-1))]})
	currpagewidth=$(cut -d "x" -f 1 <<< ${currpageinfo[2]})
	currpageheight=$(cut -d "x" -f 2 <<< ${currpageinfo[2]})
	echo -n "    -> page $curr of $pagecount (${currpagewidth}x${currpageheight}) ..."
	convert -density 300 "$1"[$((curr-1))] "$tmppath"$curr.png
	files="$files $tmppath$curr".png
	curr=$((curr+1))
	echo " done"
done

# Combine to single PDF
echo "Combining PNG images to single PDF"
convert -monitor $files "$filename"_png.pdf

# Clean up
echo "Deleting temporary files"
curr=1
while [ $curr -le $pagecount ]
do
	echo -n "    -> image $curr of $pagecount ..."
	rm "$tmppath"$curr.png
	curr=$((curr+1))
	echo " done"
done
echo -n "    -> temporary directory ..."
rmdir "$tmppath"
rmdir "/tmp/pngpdf/"
echo " done"

fi

