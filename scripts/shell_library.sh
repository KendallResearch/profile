#!/usr/bin/env bash
#
# Shared library of (hopefully) useful functions for shell scripting.
#
# Intended to be sourced from other scripts; e.g.:
#   source ~/profile/scripts/shell_library.sh

# After calling this function, you should be able to use sudo without needing a password to be
# re-entered, even in long-running scripts.
function prompt_for_sudo() {
    # Ask for the administrator password upfront
    sudo -v
    # Keep-alive: update existing `sudo` time stamp until `.osx` has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}
