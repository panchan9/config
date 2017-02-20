# .bashrc


#export PS1="[@ \033[36m\]\W\033[m\]]\\$ "
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

if [ -d /usr/local/opt/coreutils/libexec/gnubin ]; then
    export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
    export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH
    alias ls='ls --color=auto'
else
    export LSCOLORTS=gxfxcxdxbxegedabagacad
    alias lf='ls -G'
fi

export HISTCONTROL=ignoreboth

# setting for MacVim
export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
alias vi='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'
alias vim='env LANG=ja_JP.UTF-8 /Applications/MacVim.app/Contents/MacOS/Vim "$@"'

tabs -2


LS_OPT=""
if ls --help | grep 'group-directories-first' > /dev/null 2>&1; then
  LS_OPT="--group-directories-first"
fi

alias act="source ~/projects/default33/bin/activate"
alias ll='ls -ltr --time-style=long-iso'
alias la='ls -la --time-style=long-iso'
alias lf='ls -Fh --time-style=long-iso'
alias ld='ls -ld --time-style=logn-iso'
alias less='less -M'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -v'
alias chmod='chmod -v'
alias gzip='gzip -v'
alias gunzip='gunzip -v'
alias nku='nkf --overwrite -w8'

alias conda='pyenv shell anaconda3-2.0.1'
alias pv='pyenv versions'

alias fe='cd ~/dev/falcon/findechoes'

export GREP_COLOR='1;37;41'
alias grep='grep -E --color=auto'

# anyenv
if [ -d $HOME/.anyenv ]; then
    #Sphix
    SPHINX="$HOME/.anyenv/envs/pyenv/versions/3.4.1/lib/python3.4/site-packages"
    export PATH="$HOME/.anyenv/bin:$SPHINX:$PATH"
    eval "$(anyenv init -)"
fi

# User specific aliases and functions
# make symbolic links
if [ ! -L ~/.git-completion.bash ]; then
  ln -s ~/config/git-completion.bash ~/.git-completion.bash
fi

if [ ! -L ~/.gitconfig ]; then
  ln -s ~/config/.gitconfig ~/.gitconfig
fi

#if [ ! -L ~/.vimrc ]; then
#  ln -s ~/config/.vimrc ~/.vimrc
#fi

# For Git
# diff-highlight
export PATH=$PATH:/usr/local/share/git-core/contrib/diff-highlight
if [ which diff-highlight -a ! grep 'diff-highlight' ~/.gitconfig ] > /dev/null 2>&1; then
  git config --global parser.log 'diff-highlight | less'
  git config --global parser.show 'diff-highlight | less'
  git config --global parser.diff 'diff-highlight | less'
  git config --global diff.compactionHeuristic true
fi

# PostgreSQL
pg='pg_ctl -l /usr/local/var/postgres/server.log'
pgs='postgres -D /usr/local/var/postgres'

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH
