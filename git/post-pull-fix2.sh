#!/bin/sh

# Use, if post-pull-fix.sh was not sufficient
# Roll20 hat .gitattributes with * text=auto
# Kick that out with core.autocrlf=input
# Use in root dir of git repository
# Fixes some newline-related weirdness
sed -r -i -e '/^\* text=auto$/d' .gitattributes
git status
git checkout -- .gitattributes
# Yeah, discarding the changes is ok, git is satisfied

