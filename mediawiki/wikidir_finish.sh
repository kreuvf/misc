#!/bin/sh

# Part 3 of Upgrading MediaWiki
# Run this in the wiki repository, not inside the wiki folder (inside the FTP folder, not inside wiki.something/FTP/wiki.something)
# 	Get back files deleted
# 	Remove deleted files with git
# 	Add changed files with git
# 	Add new files with git
# 
# This script does no automatic committing

if [ ! -e 'wiki.dsa.isurandil.net' ];
then
	echo "Wrong working directory. Run this in the wiki repository, not inside the wiki folder (inside the FTP folder, not inside wiki.something/FTP/wiki.something)."
	exit 1
fi

# Stage 0: Report deleted files
# This allows to manually fix things.
# sed commands do
# 	Get lines of deleted files (scrap all lines not for deleted files)
# 	Remove the prefix to get a path
# 	Don't care about .signal ...
# 	... no matter where it may reside
# 	Remove entries of files/directories that do not match certain "protected" files
echo "The following files existing prior to the update will be deleted. Please have a look at these and check whether the script did accidentally not save one of those:"
git status --porcelain \
	| sed -r \
		-e '/^ D/!d' \
		-e 's|^ D ||' \
		-e '/^\.signal/d' \
		-e '/^[^/]+\/\.signal/d' \
		-e '/^[^/]+\/(LocalSettings\.php)/d' > wikidir-finish_deleted_files.log
echo "Stage 0 Clear"

# Stage 1: Recover deleted files still wanted
git status --porcelain \
	| sed -r \
		-e '/^ D/!d' \
		-e 's|^ D ||' \
		-e '/^\.signal/d' \
		-e '/^[^/]+\/\.signal/d' \
		-e '/^[^/]+\/(LocalSettings\.php)/!d' \
	| xargs git checkout --

echo "Stage 1 Clear"

git status --porcelain \
	| sed -r \
		-e '/^ D/!d' \
		-e 's|^ D ||' \
	| xargs git rm

echo "Stage 2 Clear"

git status --porcelain \
	| sed -r \
		-e '/^ M/!d' \
		-e 's|^ M ||' \
	| xargs git add

echo "Stage 3 Clear"

git status --porcelain \
	| sed -r \
		-e '/^\?\?/!d' \
		-e 's|^\?\? ||' \
		-e '/^\.signal/d' \
		-e '/^[^/]+\/\.signal/d' \
	| xargs git add

echo "Stage 4 Clear"

