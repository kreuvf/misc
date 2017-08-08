#!/bin/sh

# Use, if post-pull-fix.sh was not sufficient
# Roll20 hat .gitattributes with * text=auto
# Kick that out with core.autocrlf=input
# Use in root dir of git repository
# Fixes some newline-related weirdness
sed -r -i -e '/^\* text=auto$/d' .gitattributes
git stash
git stash drop
# Yeah, stashing and then dropping is okay, git is satisfied

