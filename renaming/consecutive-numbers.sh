# Original: https://stackoverflow.com/a/8502535
# Original Author: Pero (https://stackoverflow.com/users/591396/pero)
# Licence: https://creativecommons.org/licenses/by-sa/3.0/

# Author: Steven "Kreuvf" Koenig

# Todo:
# * New parameter prefix/suffix
# * New parameter starting number
# * New parameter end number
# * New parameter file extension
# * Get rid of predefined padding (count files to rename first, then determine required padding)

echo "This script can cause quite some harm. Therefore, you will have to type the actual commands manually. Exiting ..."
exit 0

find -name '*.jpg' | # find jpegs
sort | # Sort alphabetically
gawk 'BEGIN{ a=1 }{ printf "mv -i -- %s %04d.jpg\n", $0, a++ }' | # build mv command
bash # run that command
