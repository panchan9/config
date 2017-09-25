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
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff -u'
else
  alias diff='diff -u'
fi
export LESS='-R'


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


###-begin-npm-completion-###
#
# npm command completion script
#
# Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
# Or, maybe: npm completion > /usr/local/etc/bash_completion.d/npm
#

if type complete &>/dev/null; then
  _npm_completion () {
    local words cword
    if type _get_comp_words_by_ref &>/dev/null; then
      _get_comp_words_by_ref -n = -n @ -n : -w words -i cword
    else
      cword="$COMP_CWORD"
      words=("${COMP_WORDS[@]}")
    fi

    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$cword" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           npm completion -- "${words[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${words[cword]}"
    fi
  }
  complete -o default -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    local si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       npm completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi
###-end-npm-completion-###
