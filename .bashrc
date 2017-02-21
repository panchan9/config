# .bashrc


LS_OPT=""
if ls --help | grep 'group-directories-first' > /dev/null 2>&1; then
  LS_OPT="--group-directories-first"
fi

alias ll='ls -ltr --time-style=long-iso'
alias la='ls -la --time-style=long-iso'
alias lf='ls -Fh --time-style=long-iso'
alias ld='ls -ld --time-style=long-iso'
alias less='less -M'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -v'
alias chmod='chmod -v'
alias gzip='gzip -v'
alias gunzip='gunzip -v'
alias nku='nkf --overwrite -w8'
alias grep='grep -E --color=auto'


# User specific aliases and functions
alias brew="env PATH=${PATH/$(anyenv root)\/envs\/pyenv\/shims:/} brew"
alias vi='vim'
alias pv='pyenv versions'

# For Git
# diff-highlight
if [ which diff-highlight -a ! grep 'diff-highlight' ~/.gitconfig ] > /dev/null 2>&1; then
  git config --global parser.log 'diff-highlight | less'
  git config --global parser.show 'diff-highlight | less'
  git config --global parser.diff 'diff-highlight | less'
  git config --global interactive.diffFilter 'diff-highlight | less'
  git config --global diff.compactionHeuristic true
fi


# PostgreSQL
pg='pg_ctl -l /usr/local/var/postgres/server.log'
pgs='postgres -D /usr/local/var/postgres'

