#!/bin/sh
# gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dQUIET -dDetectDuplicateImages -dCompressFonts=true -o output.pdf input.pdf
echo "This script does nothing. Open it and see for yourself."

# Source: https://askubuntu.com/a/1492699
#
#You can use the gs command as suggested by others, but make sure you change dPDFSETTINGS to either screen, for low quality images (75 dpi), or ebook, for 150 dpi.
#
#Here's a full list of the dPDFSETTINGS to choose from (based on this link):
#
#    -dPDFSETTINGS=/screen — Low quality and small size at 72dpi.
#
#    -dPDFSETTINGS=/ebook — Slightly better quality but also a larger file size at 150dpi.
#
#    -dPDFSETTINGS=/prepress — High quality and large size at 300 dpi.
#
#_ -dPDFSETTINGS=/default — System chooses the best output, which can create larger PDF files.
#
#You use a command like the following:
#
#gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \                                                                                                                                     
#    -dNOPAUSE -dQUIET -dBATCH -dDetectDuplicateImages \
#    -dCompressFonts=true -sOutputFile=output.pdf input.pdf 
