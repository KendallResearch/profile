#!/usr/bin/env bash

# XXX: MacOS and Ubuntu show human-readable sizes differently!
LS_FLAGS='-h'  # human-readable sizes, please

######################
## Coloring support
######################

COLOR_FLAG=''
if type gdircolors &>/dev/null; then
    alias dircolors='gdircolors'
fi
if type dircolors &>/dev/null; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    COLOR_FLAG=' --color=auto'
fi

alias ls='ls ${LS_FLAGS}'
if [ `uname` = 'Darwin' ]; then
    export CLICOLOR=1

    # Requires `brew install coreutils`.  The MacOS 'ls' does not
    # support dircolors, although is does support some of the same
    # functionality through $LSCOLORS.
    if type gls &>/dev/null; then
        alias ls='gls -h${COLOR_FLAG} ${LS_FLAGS}'
    else
        RC_MSGS+="You do not have coreutils (the GNU core utilities) installed.  Try 'brew install coreutils'."
    fi
else
    alias ls="ls -h${COLOR_FLAG} ${LS_FLAGS}"
fi

######################
## Default arguments for common shell utilities
######################

# Make sed accept regexes (so that e.g. we do not have to escape the + operator).
if [ `uname` = 'Darwin' ]; then
    # Should work on all BSD-family sed
    alias s="sed -E"
else
    alias s="sed -r"
fi

# Ye olde directory stack.  Recall that ~-N and ~+N expand to what's on the stack; since the current working directory is always on the top of the stack (entry 0), this means that ~+ expands to $PWD.
# http://tldp.org/LDP/abs/html/internal.html#DIRSD
alias d="dirs -v"
alias pu="pushd"
alias po="popd"

alias wget="wget -c"  # resume downloads by default
alias scp="scp -pC"  # preserve mtime, atime, and modes; enable compression

alias head='head -n 30'
alias tail='tail -n 30'
alias grep='grep${COLOR_FLAG} -iE'
alias greprin='grep${COLOR_FLAG} -rinE'
alias fgrep='fgrep${COLOR_FLAG}'
alias egrep='egrep${COLOR_FLAG}'
alias du="du -sh"
alias df="df -hT -x tmpfs -x devtmpfs"  # -h: show human-readable sizes; -T: show partition types; -x: exclude partitions of type

alias cl="clear; l"
alias l="ls -CF"
alias ll="ls -lF"
alias la="ls -A"
alias lla='ls -lFa'
alias lS='ls -lS'

# General CLI aliases

alias trs="tr -s [:space:]"      # Replace any number of whitespace characters with a single space.
alias cuts="cut -d ' '"          # Cut with space as delimiter.  (Default is to use \t.)

function cutcol () {             # e.g. `cat foo | cutcol 1` or `cat foo | cutcol 1,2` (same as `cut -f ...`)
  trs | cuts -f "$@"             # you may override delimiter by specifying -d after the field numbers but this doesn't affect the 'tr' step
}

alias xeach="xargs -n 1"

#alias .="cd ."
alias ..="cd .."
alias ...="cd ..."
alias ....="cd ...."

alias mkdir="mkdir -pv"  # create parent dirs, and print a line for each dir created
mkcd () {
    mkdir $1 && cd $1
    # ionice classes are 0 (none), 1 (realtime), 2 (best-effort)  3 (idle)
    # nice levels go from -20 to 19 and lower is higher priority
}

######################
## Libraries and linking
######################

if [ `uname` = 'Darwin' ]; then
    alias dynamic-libs-list="otool -L"
else
    alias dynamic-libs-list="ldd"
fi

######################
## Xorg and the Linux desktop
######################

# X11 forwarding, compression on, faster ciphers
alias ssh-X="ssh -c arcfour,blowfish-cbc -XC"
# xft
alias fc-cache-rebuild="sudo fc-cache -f -v"

######################
## GUI environment / desktop stuff
######################

if [ `uname` = 'Darwin' ]; then
    # 'screencapture' comes with MacOS
    # See '-l <window id>' option to capture individual windows.  Not sure how to easily list window IDs.
    alias capture-screen="screencapture -xC"   # -x: no sound; -C: show cursor

    # Installed via 'brew install imagesnap'.  Takes a second or two to turn on the FaceTime
    # camera's green light, and the image is actually captured right before it goes off.  Total
    # runtime is about 3 seconds on my MacBook Air.  Default filename (if no argument is provided)
    # is snapshot.jpg.
    alias capture-user-photo="imagesnap"
else
    # TODO: Need Linux equivalents.
    :
fi

######################
## 802.11
######################

if [ `uname` = 'Darwin' ]; then
    # Could just symlink this into /usr/local/bin, but this way it's available immediately on a new machine.
    alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"

    alias airport-info="airport --getinfo"
    alias airport-scan="airport --scan | ksort -h -c 3 -r"  # sort by best signal strength
    alias airport-disassociate="sudo airport -z"
else
    # TODO: Need Linux equivalents.
    :
fi

######################
## Process management
######################

# Process management
# This is just like `ps -H ux` except with the fields in a different order.
#   - And added 'pri'.
# The -H adds "hierarchy" (indented process trees).
# output fields:
#  - 'ucmd' is just the command, with no arguments; 'command' is the whole thing
#  - 'vsz' is virtual memory size; 'rss' is resident memory size (actually exclusively used by the process)
#  - 'ni' is "nice value" (i.e. what `nice`, `renice` do); 'pri' is process priority (seems to be 19 by default and up is higher)
#  - 'time' is total CPU usage
#  - 'ppid' is parent PID
#  - see also... 'cpu', 'addr', 'f', 'wchan', 'c', 'cp'
# useless:
#   - 'sz' is same as 'vsz' but in page units (whereas 'vsz' is in kB)

if [ `uname` = 'Darwin' ]; then
    alias top="top -o cpu"
    export PS_FORMAT=user,tty,stat,time,vsz,rss,ni,%cpu,%mem,pid,command
    export PS_FLAGS=""
else
    # TODO: does 'tty' work for Ubuntu in place of 'tname'?
    alias top="top -S"
    export PS_FORMAT=user,tname,stat,time,vsz,rss,ni,%cpu,%mem,pid,command
    export PS_FLAGS="-H"
fi

# use full process name, not just the first 15 characters
alias pgrep="pgrep -f"

alias ps="\ps ${PS_FLAGS} xo ${PS_FORMAT}"
alias psw="\ps ${PS_FLAGS} wxo ${PS_FORMAT}"
alias psww="\ps ${PS_FLAGS} wwxo ${PS_FORMAT}"
alias psa="\ps ${PS_FLAGS} axo ${PS_FORMAT}"
alias psaw="\ps ${PS_FLAGS} waxo ${PS_FORMAT}"
alias psaww="\ps ${PS_FLAGS} wwaxo ${PS_FORMAT}"

function psgrep() {
    # We need 'ps' without the 'x' flag (which shows all processes, overriding 'p')
    \ps -H o ${PS_FORMAT} p $(pgrep "$1") | highlight "$1"
}

renice-lowest () {
    sudo ionice -p "$1" -c 3
    sudo renice -n 19 -p "$1"
}
renice-high () {
    sudo renice -n -10 -p "$1"
}
renice-highest () {
    sudo ionice -p "$1" -c 1
    sudo renice -n -20 -p "$1"
}

######################
## Use alternatives if available
######################

# For Mac OS X, which provides 'md5' instead of 'md5sum' (although I `brew install md5sha1sum`,
# which makes this unnecessary).
if [ -z $(which md5sum) ]; then
    alias md5sum="md5 -q";
    RC_MSGS+=("'md5sum' is not available; making do with 'md5'.  If on a Mac, try 'brew install md5sha1sum'.")
fi

if [ `uname` = 'Darwin' ]; then
    if [ $(which gtar) ]; then  # XXX: $(...) vs. `...` for this usage?
        alias tar="gtar"
    else
        RC_MSGS+=("The 'tar' that ships with Mac OS X is missing some features (e.g. -J for xzip compression).  Try 'brew install gnu-tar'.")
    fi
fi

if [ $(which colordiff) ]; then
    alias diff="colordiff";
else
    RC_MSGS+=("'colordiff' is not available.  Try 'brew install colordiff'.")
fi

if [ $(which ag) ]; then
    # the silver searcher!
    alias ack="ag"
    alias ackq="ag -Q"
elif [ $(which ack-grep) ]; then
    # to avoid a collision, ack's Ubuntu package has a weird name
    alias ack="ack-grep"
    alias ackq="ack-grep -Q"
elif [ $(which ack) ]; then
    alias ackq="ack -Q"
else
    RC_MSGS+=("You do not have any enhanced-grepping tools (ack, ag, etc.) available.")
fi

######################
# Make certain commands expand aliases.
######################
alias sudo="sudo " # http://serverfault.com/questions/61321/how-to-pass-alias-through-sudo
alias watch="watch "
alias xargs="xargs "

######################

alias sush="sudo -i -u"
alias root="sudo -s"
alias su="sudo -s -u"
alias reboot="sudo reboot"
alias halt="sudo halt"
alias poweroff="sudo poweroff"
alias shutdown="sudo shutdown"

# System status
alias meminfo='\free -m -l -t'
alias psmem='\ps auxf | sort -nr -k 4'
alias pscpu='\ps auxf | sort -nr -k 3'

# Package management
alias aptinstall="sudo apt-get install"
alias aptsearch="apt-cache search --names-only"
#alias aptupdate="sudo bash ~/scripts/update.sh"
alias aptquery="dpkg-query -l"

# Editing

# let emacsclient start emacs if it's not running.  emacs-nw is a tiny wrapper that calls emacs with
# the '-nw' (command-line or "no windowing") flag
export ALTERNATE_EDITOR=emacs-nw

# -nw, -t, and --tty are supposed to do the same thing
# -q : don't let emacsclient whine about connecting to remote server sockets
# -n, --no-wait : Let emacsclient exit immediately.
alias emacs-alone="TERM=xterm-16color \emacs -nw"
alias emacsd="TERM=xterm-16color \emacs --daemon"
alias emacs="TERM=xterm-16color \emacsclient -nw"
alias xemacs="TERM=xterm-16color \emacs"

# Xdefaults
alias xdefaults-reload="xrdb -merge ~/.Xdefaults"

# Rsync
alias rsync-copy="rsync --progress -azre ssh"
# rsync -r -v --compress --partial --archive --progress
# is "--rsh="ssh -l kelleyk" necessary?

# top, sorted by CPU
if [ `uname` = 'Darwin' ]; then
    alias top="top -o cpu"
else
	alias top="top -S"
fi

# SSH keys
alias removekey="ssh-keygen -f  ~/.ssh/known_hosts -R"  # e.g. `removekey 192.168.0.1`

# Networking
# netstat: (-n numerical ports only; no unix sockets and crap) (-p show program/process ID)
#   (-a show all / -l listening only) (-e 'extend'--show extra info)
# ? is this true ? the -w for raw makes it very fast, but means hostnames are not resolved
# -t only tcp

# alias netstat="netstat"
# 'derpy-netstat' alias netstat="netstat -atwn"
#alias netstat="netstat -an --inet"
alias ifip="ifconfig|grep \"inet addr\"|grep -v \"127.0.0.1\"|tr -s ' '|cut -d ' ' -f3|cut -d ':' -f2"
#alias ifaddrs="source ~/scripts/ifaddrs.sh"

alias net-open="\netstat -pe --inet -an"
alias net-listening="\netstat -pe --inet -l "
alias arp="arp -n"  # arp is very slow without -n as it waits for lots of name lookups to fail
alias route="route -n"  # same thing for route  (this utility isn't available on BSD, so prefer netstat!)
alias netstat="netstat -n"  # and for netstat

alias routes-list="netstat -nr"
alias routes-list-inet="netstat -nrf inet"
alias routes-list-inet6="netstat -nrf inet6"

# find all hosts in a subnet responding to ICMP traffic
alias nmap-discover="\nmap -sP"
# find all ports open on (and attempt to identify the OS of) a single host
alias nmap-portscan="\nmap -p- -v -A"

## From looking at someone's alises, here are some other admin tools worth looking at:
# - dnstop
# - vnstat
# - iftop
# - tcpdump
# - ethtool
# - iwconfig

# Ubuntu GUI odds and ends
alias nautilus="nautilus --no-desktop"
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ $(which xdg-open) ]; then  # Ubuntu
    alias o="xdg-open"
    alias open="xdg-open"
elif [ $(which open) ]; then  # Mac OS X
    alias o="open"
else
    RC_MSGS+="Neither 'xdg-open' nor 'open' is available; I don't know how to set 'alias o'."
fi

# XXX: clean me up; now have ~/bin in $PATH
# Custom scripts
# if [ -x ~/scripts ]; then
    #alias clone="py2 ~/scripts/clone.py"
    # alias clean="py2 ~/scripts/clean.py"
    # alias dotfiles="py2 ~/scripts/sync_dotfiles.py"
    # alias pyf="py2 ~/scripts/pyfilter.py"
    # alias rex="py2 ~/scripts/rex.py"
    # alias mssh="~/scripts/mssh.pl"
    # alias wifi="~/scripts/wifi.py"
    #alias subl="~/scripts/sublime_cli.sh"  # disabled because fuck you, sublime
# fi

# XXX: combine with 'clean' script
rclean () {
  find . -iname "*.pyc" -exec rm "{}" \;
  find . -name "__pycache__" -exec rm "{}" \;
}

# # Compression
# function xz-max {
#     # using tar options
#     tar -cf $last_arg_is_output -I 'xz -z9e -v' $all_but_last_arg
#     # unix-traditional way with pipes
#     tar cf - $all_but_last_arg | xz -z9e -v > $last_arg_is_output
# }

# Requires LibreOffice Writer
if [ $(which lowriter) ]; then
    alias doc2pdf="lowriter -convert-to pdf:writer_pdf_Export"
fi

alias todo="emacs ~/autosync/todo.org"

# Python goodies
alias pip-r="pip install -r requirements.txt"
#alias build-venv="source ~/scripts/build-virtualenv.sh"
# alias which-venv="py2 ~/scripts/which-virtualenv.py"
# alias venv="source ~/scripts/go-virtualenv.sh"
alias py2="python2.7"
alias py3="python3.3"
alias py="python"
alias pydoc="python -m pydoc" # respect virtualenv
#alias pydocp="source ~/scripts/pydocp.sh"
alias pydocp="((sleep 1; xdg-open http://localhost:5050) &) ; pydoc -p 5050"
# alias mkpy="~/scripts/mkpy.sh"

# At some point before 2.3.4, you had to use -s (shortcut for
#     --capture=no) in order to be able to use --pdb.
# -x stops after the first failure.
# --pdb enters pdb on unhandled exception.
# --showlocals (-l) prints local variables when doing so.
# "--cov-report html" tells pytest-cov to generate an HTML coverage report
#    (Note that you must specify what files to generate coverage reports for with "--cov <foo>" or
#    no coverage report will be generated.)
# Also try:
# --tb={long,native,short,line}
export PYTEST_FLAGS="-s --solid-loglevel trace --cov-report html --tb short"

alias py.test="\py.test $PYTEST_FLAGS -x --pdb --showlocals"
alias py.test-all="\py.test $PYTEST_FLAGS"
alias pytest="py.test"
alias pytest-all="py.test-all"

alias mkvenv3="mkvirtualenv -p `which python3.3` --no-site-packages --distribute"
alias mkvenv2="mkvirtualenv -p `which python2.7` --no-site-packages --distribute"
alias mkvenv="mkvenv2"
#alias mkproj3="mkproject -p `which python3` --no-site-packages"
#alias mkproj2="mkproject -p `which python2.7` --no-site-packages"
#alias mkproj="mkproj2"

# stud
alias pst='stud project -a'

# git
alias git="git-with-default-args"  # just adding default args was breaking 3rd-party stuff that
                                   # wanted to script the 'git' command
alias st="git status"
alias clone="git clone"
alias pull="git pull"
alias push="git push"
alias log="git ls"

# Fancy tricks that I should explore.
# http://www.itworld.com/it-managementstrategy/114642/unix-how-to-time-saving-aliases
find_last_modified () {
  last_modified=`ls -t | head -1`
}
alias again="find_last_modified; $EDITOR $last_modified" # open most recent again

# Lists everything in your $PATH.
function pathfind () {
  echo $PATH | tr -s ":" "\012" | xargs \ls
}
# Prints path elements one-to-a-line.
function pathecho () {
    echo -e "${PATH//:/\n}"
}


alias cpv="rsync --progress -ravz"  # show progress bar; useful even locally


##########
# Supervisor

alias profile-supervisorctl="~/.virtualenvs/profile/bin/supervisorctl -c ~/profile/supervisor/supervisord.ubuntu.conf"
alias profile-supervisor-editconfig="e ~/profile/supervisor/supervisord.ubuntu.conf"
