# .bashrc

if ! grep '~/git/pampers/.bashrc' ~/.bashrc > /dev/null 2>&1; then
	echo "
if [ -f ~/git/pampers/.bashrc ]; then
	. ~/git/pampers/.bashrc
fi
" >> ~/.bashrc
fi


# User specific aliases and functions
function parse_git_branch {
		    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function proml {
		    export PS1="\n\[\033[0;33m\][\u@\h \w]\[\033[1;35m\]\$(parse_git_branch)\[\033[0m\]\n\$ "
}
proml

export PATH=$PATH:$HOME/bin:$HOME/git/pampers/sat:$HOME/git/pampers/utils


LS_OPT=""
if ls --help | grep 'group-directories-first' > /dev/null 2>&1; then
	LS_OPT="--group-directories-first"
fi

alias c='clear'
alias l='less -gmj10'
alias ls="ls -F  --time-style=long-iso --color=auto ${LS_OPT}"
alias ll="ls -lhtr --time-style=long-iso --color=auto ${LS_OPT}"
alias la="ls -la --time-style=long-iso --color=auto ${LS_OPT}"
alias ld="ls -ld --time-style=long-iso --color=auto ${LS_OPT}"
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -v'
alias chmod='chmod -v'
alias gzip='gzip -v'
alias gunzip='gunzip -v'
alias nku='nkf --overwrite -w8'

alias pam='cd ~/git/pampers'

if [ ! -L ~/.git-completion.bash ]; then
	ln -s ~/git/pampers/git-completion.bash ~/.git-completion.bash
fi

if [ ! -L ~/.gitconfig ]; then
	ln -s ~/git/pampers/.gitconfig ~/.gitconfig
fi

if [ ! -L ~/.vimrc ]; then
	ln -s ~/git/pampers/.vimrc ~/.vimrc
fi

# for Ansible command
if [ ! -d ~/ansible-common/inv ]; then
	mkdif -pv ~/ansible-common/inv
fi

if [ ! -L ~/ansible-common/inv/prod-hosts ]; then
	ln -s ~/git/pampers/ansible/prod-hosts ~/ansible-common/inv/prod-hosts
fi

if [ which diff-highlight -a ! grep 'diff-highlight' ~/.gitconfig ] > /dev/null 2>&1; then
	echo "
[pager]
	log  = diff-highlight | less
	show = diff-highlight | less
	diff = diff-highlight | less
" >> ~/.gitconfig
fi

source ~/.git-completion.bash
