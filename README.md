profile
=======

Dotfiles, setup scripts, utilities, and so forth.

Generally supports Mac OS X and Ubuntu.

Not present: my Emacs configuration, which I keep in a separate repository.

Overview
---------------------------------

- I keep a clone of this repository (well, my fork of it) at ~/profile.  This is hardwired.  Sorry.

- The top-level subdirectories are...

   - profile/bin

     This is added to the front of your $PATH.  It contains utilities and scripts that should
     be readily accessible from a shell.  Files are named without file extensions (.sh, .py, and so on)
     and with dashes separating words.

   - profile/config

     Configuration files *for the scripts and utilities herein*.  Configuration files for the system at
     large are in /etc, and personal configuration files are in profile/dotfiles, where they belong.

   - profile/etc (profile/etc/osx, profile/etc/ubuntu)

     System-level configuration files that are either symlinked into or copied into /etc (or a
     similar, you-have-to-be-root place).

   - profile/fonts

     The fonts/common subdirectory is symlinked into fonts/osx and fonts/ubuntu so that fonts there are
     accessible on both platforms.  The platform-specific subdirectories are symlinked into the appropriate
     place for user fonts on that platform.

   - profile/scripts

     Similar to profile/bin, but things that should not clutter the $PATH.  Some of these scripts are
     referenced in dotfiles or are libraries used by things that *are* in profile/bin.

   - profile/supervisor

     Used to keep session-scope daemons running peaceably.  (Ubuntu-only right now, right?)  Emacs isn't run
     this way on either platform... yet.  Probably yet.

   - profile/scripts/setup

     System settings and software installation scripts.  Run and go get some coffee; come back to a system
     set up the way you like it.

- General naming conventions... TODO.

Getting started
---------------

- Read over and then run the appropriate scripts in profile/scripts/setup.

- Issue `dotfiles-link`.

  The script itself is in profile/bin and its configuration file (if
  e.g. you want to add more dotfiles) is in profile/config.  This will check and create symlinks
  from your home directory into ~/profile/dotfiles as appropriate.

- .ssh/authorized_keys
   Public keys only; keep private keys out of your dotfiles!

- `grep -rin kelleyk .` and change it all to your name/username/email.

Things you probably want to read over and customize
---------------------------------------------------

- .ssh/config

todo
-------

- Allow locations other than ~/profile

- Unify "trash file" definitions that are scattered in eighty different places.

- Clean up bin/terminal-color-*
