
# bash completion
if [ -f /usr/local/etc/bash_completion ]; then
    . /usr/local/etc/bash_completion
fi

# ls
export LSCOLORS=gxExcxdxCxegedabagacad
alias ls='ls -G'
alias la='ls -a'
alias ll='ls -al'

# pyenv
if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# git
export PS1='\h\[\033[00m\]:\W\[\033[31m\]$(__git_ps1 [%s])\[\033[00m\]\$ '
# Show information to prompt
GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
GIT_PS1_SHOWSTASHSTATE=true
GIT_PS1_SHOWUPSTREAM=auto

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# alias
alias sl='sl -e'
