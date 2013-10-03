#!/usr/bin/env bash

if [$# -ne 1]
then
  echo "Usage: `basename $0` <path to submodule>"
  echo "Don't include leading or trailing slashes in the path."
  echo "Must be run from repo root (blame git, not me)."
fi

MATCHES=`git submodule | awk '{print $2}' | grep "$1" | wc -l`
if [$MATCHES -ne 1]
then
  echo "I didn't find exactly one submodule by that name."
fi

echo "Removing submodule $1..."

# http://stackoverflow.com/questions/1260748/how-do-i-remove-a-git-submodule

echo "\nRebasing against HEAD\n"
git rebase HEAD # why is this 'a good idea'?

echo "\nRemoving submodule from index\n"
git rm --cached $1

echo "\nRemoving sections from .gitmodules and .git/config\n"
git config -f .git/config --remove-section submodule.$1
git config -f .gitmodules --remove-section submodule.$1

echo "\nRemoving .git/modules/$1\n"
rm -rf .git/modules/$1

echo "Done."
