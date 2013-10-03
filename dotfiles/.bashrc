#!/usr/bin/env bash

########################################
## for debugging this script
########################################

# set -x  # bash tracing

# colon means "true" and is used as a no-op.
#debug_print() { :; return 0; }
# XXX: It's important that debug_print() always be truthy.
#debug_print() { echo -n "."; return 0; }
 debug_print() { echo "$@"; return 0; }
RC_MSGS=()


# Remember that you can use `alias cmd` to see what a command will produce.
# Non-alias bash fun:
#  Ctrl-R   Search through history
#  Ctrl-L   Clear screen


#########
# for file in ~/.{aliases,functions,extra}; do
# 	[ -r "$file" ] && source "$file"
# done
# unset file

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples


# If not running interactively, don't do anything
[ -z "$PS1" ] && return

########################################
## Figure out what's going on.
########################################

# At the end of this mess, KK_OS and KK_ARCH should be set.
# KK_OS \in {"darwin", "ubuntu"}
# KK_ARCH \in ("x86_64"}
function kk-detect-situation () {

    # On MacOS 10.8.5, both the default bash and Homebrew's bash report OSTYPE="darwin12".
    # On Ubuntu 13.04, bash reports OSTYPE="linux-gnu".

    # Other values reported by The Internet:
    # cygwin (Cygwin); darwin9.0 (Leopard); darwin10.0 (Snow Leopard)

    case $OSTYPE in
        darwin*)    export KK_OS="darwin"    ;;
        linux-gnu)  export KK_OS="linux"     ;;
        *)          export KK_OS="unknown"   ;;
    esac

    # NTS: on RedHat, '/etc/redhat-release' will exist.
    if [[ "$KK_OS" == "linux" ]]; then
        source /etc/lsb-release
        if [[ "$DISTRIB_ID" == "Ubuntu" ]]; then
            export KK_OS="ubuntu"
            export KK_OS_VERSION="$DISTRIB_RELEASE"
            export KK_OS_CODENAME="$DISTRIB_CODENAME"
        else
            export KK_PLATFORM="unknown"
            RC_MSGS+=("Unknown Linux variant: /etc/lsb-release says DISTRIB_ID=$DISTRIB_ID")
        fi
    elif [[ "$KK_OS" == "unknown" ]]; then
        RC_MSGS+=("I don't recognize OSTYPE=$OSTYPE")
    fi

    local UNAME_P=`uname -p`
    if [ "$UNAME_P" == 'x86_64' ]; then
        KK_ARCH="x86_64"
    else
        KK_ARCH="unknown"
        RC_MSGS+=("Unknown hardware platform: $UNAME_P")
    fi
}
kk-detect-situation

########################################
## bash completion
########################################

function binary-available () {
    type "$1" &> /dev/null
}

# XXX: Complain if this is Darwin and there is no brew.
# Enable bash completion on MacOS X.  For some reason, putting this before the aliases makes
# everything much faster.
#if type brew &>/dev/null; then
if binary-available brew; then
    debug_print "We have brew..."
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        debug_print "...enabling bash_completion..."
        source $(brew --prefix)/etc/bash_completion
        debug_print "...done!"
    fi
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
# @KK: Looks like, on Mac OS X, at least, /etc/profile doesn't.
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    debug_print "Sourcing /etc/bash_completion."
    source /etc/bash_completion
fi

########################################
## bash options and "standard" variables
########################################

debug_print "Setting bash options..."

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# use `history` to get history
HISTSIZE=32768
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignoredups               # Don't put duplicate lines in the history.
HISTIGNORE=ls:cd:clear               # Screw useless filler commands.

shopt -s nocaseglob                  # Case-insensitive globbing (used in pathname expansion)
shopt -s histappend                  # Append to the Bash history file, rather than overwriting it
#shopt -s cdspell                    # Autocorrect typos in path names when using `cd`
shopt -s checkwinsize                # Update LINES and COLUMNS (if necessary) after each command.
shopt -s autocd 2> /dev/null         # (Bash 4 only.)  `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
shopt -s globstar 2> /dev/null       # (Bash 4 only.)  Recursive globbing, e.g. `echo **/*.txt`

unset MAILCHECK                      # No more "you have new mail".

export FIGNORE="~:#:.pyc"                   # Ignore certain files when completing filenames.


debug_print "Setting environmental variables..."

export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

export PAGER=`which less`
export MANPAGER='less -X'             # Don't clear the screen after leaving a manual page.
export LESS_TERMCAP_md="$ORANGE"      # Highlight section titles in man pages.

export BROWSER=`which google-chrome`  # Can be invoked with `sensible-browser`.

export EDITOR=emacs-nw                # Tiny wrapper that invokes `emacs -nw`.
export VISUAL=emacs
export SUDO_EDITOR=emacs              # Use with `sudoedit` or `sudo -e` instead of `sudo emacs`.
export ALTERNATE_EDITOR=emacs-nw      # let emacsclient start emacs if it's not running

# These are necessary because secure_path will prevent our post-sudo commands from finding emacs-nw in ~/bin.
# export SUDO_EDITOR=emacs
# export SUDO_VISUAL=emacs

# from sudo(8):
# SUDO_ASKPASS     Specifies the path to a helper program used to read the
#                  password if no terminal is available or if the -A option
#                  is specified.
# SUDO_PROMPT      Used as the default password prompt.
# SUDO_PS1         If set, PS1 will be set to its value for the program
#                  being run.
# SUDO_EDITOR      Default editor to use in -e (sudoedit) mode.
# SUDO_GID         Set to the group ID of the user who invoked sudo.
# SUDO_COMMAND     Set to the command run by sudo.
# SUDO_UID         Set to the user ID of the user who invoked sudo.
# SUDO_USER        Set to the login name of the user who invoked sudo.

# Notes:
# - Per visudo(8), visudo chooses VISUAL, then EDITOR.
#   Per vipw(8), vipw and vigr behave the same way.
#   No word on how they behave w.r.t. SUDO_VISUAL, SUDO_EDITOR.

########################################
## general-purpose variables
########################################

if [ -f /var/log/system.log ]; then
    export SYSTEM_LOG=/var/log/system.log   # Darwin
elif [ -f /var/log/syslog ]; then
    export SYSTEM_LOG=/var/log/syslog       # Ubuntu
fi

########################################
## Functions, aliases, and extensions
########################################

# N.B.: 'z' appends something to $PROMPT_COMMAND (to tell itself about new directories); this zaps $?.
if [ -f ~/profile/vendor/z/z.sh ]; then
    debug_print "z: Enabling..."
    source ~/profile/vendor/z/z.sh
else
    RC_MSGS+=("z: Not found!")
fi
# # # Basic prompt setup
# debug_print "Setting up prompt (.bash_prompt)..."
# source ~/.bash_prompt

debug_print ".bash_venv_cd: Setting up automatic virtualenv management..."
source ~/profile/dotfiles/.bash_venv_cd

# git-specific prompt fanciness.
debug_print ".bash_prompt: Setting up prompt..."
source ~/profile/dotfiles/.bash_prompt

# Alias definitions.  See /usr/share/doc/bash-doc/examples in the
# bash-doc package.
debug_print ".bash_aliases: Setting up aliases..."
source ~/profile/dotfiles/.bash_aliases

########################################

# If this is an xterm set the title to user@host:dir
case "$TERM" in
    xterm*|rxvt*)
        debug_print "This looks like an xterm."
        PS1="\[\e]0;\u@\h: \w\a\]$PS1"
        ;;
    *)
        debug_print "Not sure what sort of terminal this is."
        ;;
esac

# Execute machine-specific goodies.
debug_print "Executing machine-specific bashrc (.bashrc.local) if it exists..."
if [ -r ~/.bashrc.local ]; then
    debug_print ".bashrc.local: Sourcing machine-specific bashrc..."
    source ~/.bashrc.local
else
    debug_print ".bashrc.local: Machine-specific bashrc does not exist; skipping."
fi

########################################
## Darwin-specific
########################################

if [ "$KK_OS" == "darwin" ]; then
    # Use Homebrew-installed binaries first, followed by pip-installed (Python) binaries.
    export PATH=/usr/local/bin:/usr/local/share/python:$PATH

    # Apple's system Python doesn't check this directory, causing pygtk
    # installed by Homebrew not to be found (which is problematic for
    # e.g. meld).
    export PYTHONPATH=/usr/local/lib/python2.7/site-packages:$PYTHONPATH

    # Use NPM modules.
    export NODE_PATH=/usr/local/lib/node_modules:$NODE_PATH

    # Put global binaries installed by npm (e.g. via `npm install -g`) in the PATH.
    export PATH=$PATH:/usr/local/share/npm/bin
fi

########################################
## ...
########################################

# ~/bin is symlinked to ~/profile/bin
if [ -x ~/profile/bin ]; then
    debug_print "Putting ~/profile/bin at front of \$PATH..."
	export PATH=$HOME/profile/bin:$PATH
else
    RC_MSGS+=("~/profile/bin: Not found!")
fi

# ### XXX TODO: lesspipe.sh from homebrew; untested!
# # make less more friendly for non-text input files, see lesspipe(1)
# [ -n `which lesspipe.sh` ] && eval "$(SHELL=/bin/sh lesspipe.sh)"

########################################
## ...
########################################

debug_print ".bashfn: Sourcing utility functions..."
source ~/profile/dotfiles/.bashfn

########################################
## Python
########################################

if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    # Ubuntu
    debug_print "virtualenvwrapper: Sourcing (Ubuntu)..."
    source /usr/local/bin/virtualenvwrapper.sh
elif [ -f /usr/local/share/python/virtualenvwrapper.sh ]; then
    # Homembrew pip
    debug_print "virtualenvwrapper: Sourcing (Homebrew pip)..."
    source /usr/local/share/python/virtualenvwrapper.sh
else
    RC_MSGS+=("virtualenvwrapper: NOT FOUND; skipping.")
fi

# Prevent .pyc trash.
export PYTHONDONTWRITEBYTECODE=1

#[[ -s "$HOME/.pythonbrew/etc/bashrc" ]] && source "$HOME/.pythonbrew/etc/bashrc"
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

(binary-available pip) && eval "`pip completion --bash`"
#(which pip &>/dev/null) && eval "`pip completion --bash`"

########################################
## Ruby
########################################

if [ $(which rbenv) ]; then
    debug_print "rbenv: Initializing Ruby..."
    eval "$(rbenv init -)";
else
    RC_MSGS+=("rbenv: NOT FOUND; skipping.")
fi

########################################
## ...
########################################

# For ssh's ControlPath.
debug_print "Creating ~/.ssh/auth/ if not present..."
\mkdir -p -v ~/.ssh/auth/

########################################
## emacs
########################################

# XXX: should run emacs daemon somewhere else
# XXX: add nohup?
# # debug_print "Checking for `emacs --daemon`..."
if [ `uname` != 'Darwin' ]; then
    if [ -z $(pidof "emacs --daemon") ]; then
        debug_print "Emacs daemon not found; starting."
        \emacs --daemon &> /dev/null &
    else
        debug_print "Emacs daemon is already running."
    fi
fi

########################################
## git-annex
########################################

if binary-available git-annex; then
    ANNEX_DATE=`git-annex version | head -n 1 | cut -d ':' -f 2 | cut -d '.' -f 2`
    debug_print "git-annex: installed at version $ANNEX_DATE."
    if [[ "$ANNEX_DATE" -lt "20130802" ]]; then
        RC_MSGS+=("You are using an outdated version of git-annex from $ANNEX_DATE.")
    fi

    alias annex='git annex'
    alias annex-sync='git annex sync --auto'
else
    RC_MSGS+=("You do not have git-annex installed.")
fi

########################################
## Finish up with some login warnings...
########################################

# XXX: don't append anything if not dirty; also, this function
#      includes a newline if they are dirty.
debug_print "Checking that dotfiles are current..."
RC_MSGS+=("$(dotfiles-check-if-dirty)")

kk_echo_red() {
    KK_SOLCOLOR_RED=$'\e[1;31m'
    COLOR_NORMAL=$'\e[m'

    echo "${KK_SOLCOLOR_RED}${1}${COLOR_NORMAL}"
}

debug_print "Finished with .bash.rc."
# XXX: this is not working!
#if [ ! -z "${#RC_MSGS[@]}" ]; then echo ""; else echo "(No warnings!)"; fi
echo ""
for msg in "${RC_MSGS[@]}"; do
  kk_echo_red "$msg"
done
unset RC_MSGS

# set -x  # bash tracing (but let's skip .bashrc)
