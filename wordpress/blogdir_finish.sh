#!/bin/sh

# Part 3 of Upgrading WordPress
# Run this in the blog repository to
# 	get back files deleted outside WordPress's wp-admin and wp-include directories
# 		NOTE: This might leave root level wp-something.php files in
# 	Remove deleted files with git
# 	Add changed files with git
# 	Add new files with git
# 
# This script does no automatic committing

git status --porcelain \
	| sed -r \
		-e '/^ D/!d' \
		-e 's|^ D ||' \
		-e '/^\.signal/d' \
		-e '/^wp-(admin|include)/d' \
	| xargs git checkout --

git status --porcelain \
	| sed -r \
		-e '/^ D/!d' \
		-e 's|^ D ||' \
	| xargs git rm

git status --porcelain \
	| sed -r \
		-e '/^ M/!d' \
		-e 's|^ M ||' \
	| xargs git add

git status --porcelain \
	| sed -r \
		-e '/^\?\?/!d' \
		-e 's|^\?\? ||' \
		-e '/^\.signal/d' \
	| xargs git add

