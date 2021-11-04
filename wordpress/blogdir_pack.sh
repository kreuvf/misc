#!/bin/bash

# Part 4 of Upgrading WordPress
# Run this in the blog repository to
# 	create a (temporary) directory upgrade-to-x.x.x
# 		NOTE: Version information is taken from most recent git log
# 	copy all required files into the temporary directory
# 	create a tarball of the directory
# 	calculate a sha256 hash
# 
# You need to upload that tarball and unpack it on the server using tar-unpack.php.
# tar-unpack.php uses the sha256 hash to verify the integrity of the archive.

# Check if this is a blog directory
if [ ! -d "wp-admin" ];
then
	echo "No 'wp-admin' directory found. This does not look like a blog directory. Aborting ...";
	exit 1;
fi
if [ ! -d "wp-content" ];
then
	echo "No 'wp-content' directory found. This does not look like a blog directory. Aborting ...";
	exit 1;
fi
if [ ! -d "wp-includes" ];
then
	echo "No 'wp-includes' directory found. This does not look like a blog directory. Aborting ...";
	exit 1;
fi
if [ ! -f "wp-config.php" ];
then
	echo "No 'wp-config.php' file found. This does not look like a blog directory. Aborting ...";
	exit 1;
fi

# Get current version number
VERSION="0.0.0";
VERSION=`git show --no-patch --format=%f | sed -r -e 's/^.*([0-9]+\.[0-9]+\.[0-9]+(\.[0-9a-z]+)?)$/\1/'`;

# Create temporary directory
TEMPDIR="upgrade-to-$VERSION";

if [ -d "$TEMPDIR" ];
then
	echo "'$TEMPDIR' already existing. Maybe a leftover from the last run of this script? Aborting ...";
	exit 2;
fi

mkdir "$TEMPDIR";

# Copy all files
find . \
	-maxdepth 1 \
	! -name '.' \
	! -name "$TEMPDIR" \
	-regextype posix-extended \
	-iregex '^.*$' \
	! -name '.git' \
	! -name '.gitignore' \
	! -name '.signal' \
	-exec cp --recursive --preserve "{}" "$TEMPDIR" \;

# Create tarball
tar --create --file="$TEMPDIR.tar" "$TEMPDIR"

# Remove temporary directory
rm --interactive=once --recursive --dir "$TEMPDIR"

