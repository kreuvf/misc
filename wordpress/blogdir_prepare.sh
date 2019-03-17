#!/bin/bash

# Copying the new files over to the blog repository will lead to the retention of unused files.
# In the worst case, this could pose security issues.

# This script tries not to do anything unless absolutely sure. 

# Let's see whether we are in the right directory
# Using .signal files to make checking easier
if [ ! -e ".signal" ];
then
	echo "'.signal' not found. Aborting ..."
	exit 1
fi
if [ ! -f ".signal" ];
then
	echo "'.signal' is not a file. Aborting ..."
	exit 2
fi
if [ ! -r ".signal" ];
then
	echo "'.signal' is not readable. Aborting ..."
	exit 3
fi
if [ ! -s ".signal" ];
then
	echo "'.signal' is empty. Aborting ..."
	exit 4
fi
if [ ! -w ".signal" ];
then
	echo "'.signal' is not writable. Aborting ..."
	exit 5
fi


# Examine the .signal file
SIGNAL=`grep -E --count '^Prepare blog directory: no$' .signal`
if [ $SIGNAL -gt 0 ];
then
	echo "'.signal' contains 'Prepare blog directory: no' line. Stopping here."
	exit 0
fi

SIGNAL=`grep -E --count '^Prepare blog directory: yes$' .signal`
if [ $SIGNAL -eq 0 ];
then
	echo "'.signal' does not contain 'Prepare blog directory: yes' line. Aborting ..."
	exit 6
fi


# Check whether we are in a repository
REPOCHECK=`git status > /dev/null | grep -E --count '^fatal: Not a git repository'`
if [ $REPOCHECK -gt 0 ];
then
	echo "Not in a repository. Aborting ..."
	exit 7
fi


# Examine repository state
# Only proceed if there are no uncommitted or staged changes.
REPOSTATE=`git status --porcelain 2> /dev/null | grep -E --count '^(M  | M )'`
if [ $REPOSTATE -gt 0 ];
then
	echo "Repository contains uncommitted or staged changes. Cannot proceed. Aborting ..."
	exit 8
fi


# Looks like we are good to go (I bet I forgot to check for something important ^.^)
# Delete all tracked files (with exceptions)
# Try to delete all tracked directories (directories are tracked only if there is a file inside)
git ls-files -z \
	| sed -r \
		-e 's|\.gitignore\x0||' \
		-e 's|wp-content(/[^\x0]*)?\x0||g' \
	| xargs -0 rm -f

git ls-tree --name-only -d -r -z HEAD \
	| sed -r \
		-e 's|wp-content(/[^\x0]*)?\x0||g' \
	| tac \
	| xargs -0 rmdir --ignore-fail-on-non-empty --parents

# Finish by setting all relevant signals to "no"
sed -r -i -e 's|^(Prepare blog directory: )yes$|\1no|' .signal

