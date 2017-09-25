#.bash_profile

####################################
# Define Environment Variables
####################################

### Prompt ###
####################################

# git prompt
source ~/.git-completion.bash
source ~/.git-prompt.sh

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUPSTREAM=auto
GIT_PS1_SHOWUNTRACKEDFILES=
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWCOLORHINTS=1

export PS1='\[\033[1;32m\]\[\033[00m\]\[\033[1;34m\]\w\[\033[1;31m\]$(__git_ps1)\[\033[00m\] \$ '


### PATH ###
####################################
# homebrew
export PATH=/usr/local/sbin:$PATH

# coreutils
if [ -d /usr/local/opt/coreutils/libexec/gnubin ]; then
    export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
    export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH
    alias ls='ls --color=auto'
else
    export LSCOLORTS=gxfxcxdxbxegedabagacad
    alias lf='ls -G'
fi

# diff-highlight for Git
export PATH=$PATH:/usr/local/share/git-core/contrib/diff-highlight


### Command History ###
####################################

# ignoreboth includes two options
## ignoredups: ignore duplicated command histories
## ignorespace:  exclude commands with space at the top of the line from history
export HISTCONTROL=ignoreboth
export HISTSIZE=5000
# exclude commands, whose char length is 3 and less, or exit
export HISTIGNORE=?:??:???:exit


# setting for MacVim
# export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim

export GREP_COLOR='1;37;41'

# PostgreSQL
export PGDATA=/usr/local/var/postgres

# anyenv
if [ -d ~/.anyenv ]; then
    export PATH="$HOME/.anyenv/bin:$PATH"
    eval "$(anyenv init -)"
fi

# pyenv-virtualenv
if [ -d $(pyenv root) ]; then
	eval "$(pyenv virtualenv-init -)"
fi

# Java
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`


if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi
