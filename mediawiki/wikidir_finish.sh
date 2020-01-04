#!/bin/sh

# Part 3 of Upgrading MediaWiki
# Run this in the wiki repository, not inside the wiki folder (inside the FTP folder, not inside wiki.something/FTP/wiki.something)
# 	Get back files deleted
# 	Remove deleted files with git
# 	Add changed files with git
# 	Add new files with git
# 
# This script does no automatic committing

# Stage 1: Recover deleted files still wanted
# sed commands do
# 	Get lines of deleted files (scrap all lines not for deleted files)
# 	Remove the prefix to get a path
# 	Don't care about .signal ...
# 	... no matter where it may reside
# 	Do not care about deletions in includes/, extensions/Cite/tests/, extensions/ParserFunctions/tests/, extensions/WikiEditor/tests/, maintenance/, resources/, serialized/, skins/, tests/ and vendor/
git status --porcelain \
	| sed -r \
		-e '/^ D/!d' \
		-e 's|^ D ||' \
		-e '/^\.signal/d' \
		-e '/^[^/]+\/\.signal/d' \
		-e '/^[^/]+\/(includes|extensions\/(Cite|ParserFunctions|WikiEditor)\/tests|maintenance|resources|serialized|skins|tests|vendor)/d' \
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

