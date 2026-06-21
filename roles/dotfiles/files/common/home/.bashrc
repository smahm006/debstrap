# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *)   return ;;
esac

# HSTR history search
shopt -s histappend
export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hstr -- \C-j"'; fi
if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hstr -k \C-j"'; fi

shopt -s checkwinsize

# Chroot label
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# Bash completion
if ! shopt -oq posix; then
  if   [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Prompt — colour varies by hostname
WHITE="\[\e[00m\]"
BOLD_GREEN="\[\e[1;32m\]"
BOLD_ORANGE="\[\e[1;33m\]"
BOLD_YELLOW="\[\e[1;93m\]"
BOLD_BLUE="\[\e[1;34m\]"
BOLD_RED="\[\e[1;31m\]"
SELECT="if [ \$? = 0 ]; then echo \"${BOLD_GREEN}\"; else echo \"${BOLD_RED}\"; fi"
case $HOSTNAME in
  sm-laptop)  HOST="${BOLD_GREEN}"  ;;
  sm-desktop) HOST="${BOLD_YELLOW}" ;;
  sm-server)  HOST="${BOLD_ORANGE}" ;;
  sm-rpi)     HOST="${BOLD_ORANGE}" ;;
  *)          HOST="${BOLD_BLUE}"   ;;
esac
export PS1="${WHITE}┌─${BOLD_BLUE} \A ${HOST}\u${WHITE}@${HOST}\h\[\e[00m\]${WHITE}: ${BOLD_BLUE}\w${WHITE}\n└─╼\`${SELECT}\`>> ${WHITE}"

# Custom environment (base + drop-in overrides)
. "$HOME/.config/bash/environment"
if [ -d "$HOME/.config/bash/environment.d" ]; then
  for i in "$HOME/.config/bash/environment.d/"*; do
    [ -r "$i" ] && . "$i"
  done
  unset i
fi

# Custom aliases
. "$HOME/.config/bash/alias"
if [ -d "$HOME/.config/bash/alias.d" ]; then
  for i in "$HOME/.config/bash/alias.d/"*; do
    [ -r "$i" ] && . "$i"
  done
  unset i
fi

# Custom functions
. "$HOME/.config/bash/function"
if [ -d "$HOME/.config/bash/function.d" ]; then
  for i in "$HOME/.config/bash/function.d/"*; do
    [ -r "$i" ] && . "$i"
  done
  unset i
fi

# GPG agent as SSH agent
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null
