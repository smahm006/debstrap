# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# HSTR configuration - shell history
# append new history items to .bash_history
shopt -s histappend
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
# if this is interactive shell, then bind hstr to Ctrl-r
if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hstr -- \C-j"'; fi
# if this is interactive shell, then bind 'kill last command' to Ctrl-x k
if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hstr -k \C-j"'; fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
	debian_chroot=$(cat /etc/debian_chroot)
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# sudo apt-get install bash-completion
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# PS1 prompt
WHITE="\[\e[00m\]"
BOLD_GREEN="\[\e[1;32m\]"
BOLD_ORANGE="\[\e[1;33m\]"
BOLD_YELLOW="\[\e[1;93m\]"
BOLD_BLUE="\[\e[1;34m\]"
BOLD_RED="\[\e[1;31m\]"
SELECT="if [ \$? = 0 ]; then echo \"${BOLD_GREEN}\"; else echo \"${BOLD_RED}\"; fi"
case $HOSTNAME in
sm-laptop) HOST="${BOLD_GREEN}" ;;
sm-desktop) HOST="${BOLD_YELLOW}" ;;
sm-server) HOST="${BOLD_ORANGE}" ;;
esac
export PS1="${WHITE}┌─${BOLD_BLUE} \A ${HOST}\u${WHITE}@${HOST}\h\[\e[00m\]${WHITE}: ${BOLD_BLUE}\w${WHITE}\n└─╼\`${SELECT}\`>> ${WHITE}"

# Custom Environment
. "$HOME/.config/bash/environment"
if [ -d "$HOME/.config/bash/environment.d" ]; then
  for i in "$HOME/.config/bash/environment.d/*"; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

# Custom Aliases
. "$HOME/.config/bash/alias"
if [ -d "$HOME/.config/bash/alias.d" ]; then
  for i in "$HOME/.config/bash/alias.d/*"; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

# Custom Functions
. "$HOME/.config/bash/function"
if [ -d "$HOME/.config/bash/function.d" ]; then
  for i in "$HOME/.config/bash/function.d/*"; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi

# GPG
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null
. "/home/smahm/workstation/architecture/toolchains/rust/.cargo/env"
