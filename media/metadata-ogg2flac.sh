#!/bin/bash

# Metadata transfer script from OGG files to FLAC files (not in OGG containers)
# While this script does some sanity checking, there are several assumptions:
# 	* every .ogg file can be read by soxi
#	* every content reported by soxi -a from a .ogg file can be applied to .flac files with metaflac
# 	* every .flac file can be manipulated by metaflac
#	* the user has read/write access to the directory/directories given
#
# Limitations
# *.oga files are not taken into account.
# All of the above assumptions.
# This has not been tested with shells other than bash.


EXIT_CODE=0

# Exit code definitions
E_NOPARAM=64
M_NOPARAM="Error: No parameters specified."

E_COMMONNODIR=65
M_COMMONNODIR="Error: Parameter <common directory> is not a directory."

E_OGGNODIR=66
M_OGGNODIR="Error: Parameter <ogg directory> is not a directory."

E_FLACNODIR=67
M_FLACNODIR="Error: Parameter <flac directory> is not a directory."

E_COMMONOGGMISS=68
M_COMMONOGGMISS="Error: No *.ogg files in the common directory."

E_COMMONFLACMISS=69
M_COMMONFLACMISS="Error: No *.flac files in the common directory."

E_OGGMISS=70
M_OGGMISS="Error: No *.ogg files in the OGG directory."

E_FLACMISS=71
M_FLACMISS="Error: No *.flac files in the FLAC directory."

E_NOMATCH=72
M_NOMATCH="Error: No matches between *.ogg files in the OGG directory and *.flac files in the FLAC directory."

E_TOOMANY=73
M_TOOMANY="Error: Too many arguments."

M_USAGE="Usage: metadata-ogg2flac.sh <common directory>
       metadata-ogg2flac <ogg directory> <flac directory>"


# Helper functions
function getOggNames () {
	find "$1" -maxdepth 1 -regextype posix-extended -regex '.*\.ogg$'
}

function getFlacNames () {
	find "$1" -maxdepth 1 -regextype posix-extended -regex '.*\.flac$'
}

function getOggCount () {
	getOggNames "$1" | wc -l
}

function getFlacCount () {
	getFlacNames "$1" | wc -l
}


# Step 0: Input Sanitation
case "$#" in
0)
	M_ERROR=$M_NOPARAM
	EXIT_CODE=$E_NOPARAM
	;;
1)
	if ! [ -d "$1" ]
	then
		M_ERROR=$M_COMMONNODIR
		EXIT_CODE=$E_COMMONNODIR
	else
		OGGDIR="$1"
		FLACDIR="$1"
		NUMBER_OGG=0
		NUMBER_OGG="$(getOggCount "$OGGDIR")"
		# " # Comment required to work around a gEdit syntax highlighting bug
		NUMBER_FLAC=0
		NUMBER_FLAC="$(getFlacCount "$FLACDIR")"
		# " # Comment required to work around a gEdit syntax highlighting bug
		if [ $NUMBER_OGG -eq 0 ]
		then
			M_ERROR=$M_COMMONOGGMISS
			EXIT_CODE=$E_COMMONOGGMISS
		elif [ $NUMBER_FLAC -eq 0 ]
		then
			M_ERROR=$M_COMMONFLACMISS
			EXIT_CODE=$E_COMMONFLACMISS
		fi
	fi
	;;
2)
	if ! [ -d "$1" ]
	then
		M_ERROR=$M_OGGNODIR
		EXIT_CODE=$E_OGGNODIR
	else
		OGGDIR="$1"
		NUMBER_OGG=0
		NUMBER_OGG="$(getOggCount "$OGGDIR")"
		# " # Comment required to work around a gEdit syntax highlighting bug
		if [ $NUMBER_OGG -eq 0 ]
		then
			M_ERROR=$M_OGGMISS
			EXIT_CODE=$E_OGGMISS
		fi
	fi
	if ! [ -d "$2" ]
	then
		M_ERROR=$M_FLACNODIR
		EXIT_CODE=$E_FLACNODIR
	else
		FLACDIR="$2"
		NUMBER_FLAC=0
		NUMBER_FLAC="$(getFlacCount "$FLACDIR")"
		# " # Comment required to work around a gEdit syntax highlighting bug
		if [ $NUMBER_FLAC -eq 0 ]
		then
			M_ERROR=$M_FLACMISS
			EXIT_CODE=$E_FLACMISS
		fi
	fi
	;;
*)
	M_ERROR=$M_TOOMANY
	EXIT_CODE=$E_TOOMANY
esac

if [ $EXIT_CODE -gt 0 ]
then
	echo "$M_ERROR

$M_USAGE"
	exit $EXIT_CODE
fi


# Step 1: Get *.ogg file list
# Inspired by https://stackoverflow.com/a/23357277
declare -a oggFiles

while IFS=  read -r -d $'\0';
do
	oggFiles+=("$REPLY")
done < <(find "$OGGDIR" -maxdepth 1 -regextype posix-extended -regex '.*\.ogg$' -print0)


# Step 2: Get *.flac file list
declare -a flacFiles

while IFS=  read -r -d $'\0';
do
	flacFiles+=("$REPLY")
done < <(find "$FLACDIR" -maxdepth 1 -regextype posix-extended -regex '.*\.flac$' -print0)


# Step 3: Strip the extensions
counter=0

for oggFile in "${oggFiles[@]}"
do
	oggFiles[$counter]="$(echo "$oggFile" | rev | cut --delimiter=. --fields=1 --complement | cut --delimiter=/ --fields=1 | rev)"
	let counter=counter+1
done

counter=0

for flacFile in "${flacFiles[@]}"
do
	flacFiles[$counter]="$(echo "$flacFile" | rev | cut --delimiter=. --fields=1 --complement | cut --delimiter=/ --fields=1 | rev)"
	let counter=counter+1
done


# Step 4: Keep only base filenames which are in both lists
# Inspired by https://stackoverflow.com/a/3686056
declare -a sameFiles

# Iterate over all OGG files, compare with each FLAC file and save matches
for oggFile in "${oggFiles[@]}"
do
	for flacFile in "${flacFiles[@]}"
	do
		if [ "$oggFile" == "$flacFile" ]
		then
			sameFiles+=("$oggFile")
		fi
	done
done

# No matches? End this
if [ "${#sameFiles}" -eq 0 ]
then
	echo "$M_NOMATCH"
	EXIT_CODE=$E_NOMATCH
	exit $EXIT_CODE
fi


# Next steps work on "all" files somehow, loop only once
for file in "${sameFiles[@]}"
do
	# Step 5: Save tags from OGG files to *.ogg.tags files
	soxi -a "$OGGDIR"/"$file".ogg | grep --invert-match -E '=$' | grep --invert-match -E '^REPLAYGAIN.*0(\.0+)?$' > "$OGGDIR"/"$file".tags


	# Step 6: Remove tags from FLAC files
	# This is necessary, because metaflac does not overwrite existing tags
	metaflac --remove-all-tags "$FLACDIR"/"$file".flac


	# Step 7: Apply tags from OGG files to FLAC files
	metaflac --import-tags-from="$OGGDIR"/"$file".tags "$FLACDIR"/"$file".flac


	# Step 8: Delete files with tags
	rm "$OGGDIR"/"$file".tags
done

exit 0
