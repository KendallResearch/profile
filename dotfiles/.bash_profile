#!/usr/bin/env bash

[ -r ~/.bashrc ] && source ~/.bashrc

# if [ `uname` = Darwin ]; then

#     # This file is sourced by login shells, and bashrc is sourced by
#     # non-login shells.  The latter works fine on Linux, but on MacOS,
#     # every terminal is a login shell!
#     [ -r ~/.bashrc ] && source ~/.bashrc

# else

# 	# TODO: for some reason, this is getting run with every shell.
# 	:

#     # # Python takes a minute to run, so do our syncing only at login
#     # # instead of every time we open a prompt.
#     # if [ -r ~/scripts/sync_dotfiles.py ]; then
# 	#     python ~/scripts/sync_dotfiles.py -q
#     # else
# 	#     echo "Cannot find ~/scripts/sync_dotfiles.py"
#     # fi

# fi

