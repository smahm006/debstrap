# System directories
export XDG_CONFIG_DIRS="/etc/xdg"
export XDG_DATA_DIRS="/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share'"

# User directories
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_BIN_HOME="$HOME/.local/bin"
if test -z "${XDG_RUNTIME_DIR}"; then
   export XDG_RUNTIME_DIR=/tmp/${UID}-runtime-dir
   if ! test -d "${XDG_RUNTIME_DIR}"; then
       mkdir "${XDG_RUNTIME_DIR}"
       chmod 0700 "${XDG_RUNTIME_DIR}"
   fi
fi

# XDG_CACHE_HOME directories
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export SOLARGRAPH_CACHE="$XDG_CACHE_HOME/solargraph"

# XDG_CONFIG_HOME directories
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"
export WGETRC="$XDG_CONFIG_HOME/wgetrc/config"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export GIT_CONFIG="$XDG_CONFIG_HOME/git/config"
export VIMINIT="set nocp | source $XDG_CONFIG_HOME/vim/vimrc"

# XDG_DATA_HOME directories
export PYTHONUSERBASE="$XDG_DATA_HOME/python"
export WINEPREFIX="$XDG_DATA_HOME/wine"
export NPMUSERBASE="$XDG_DATA_HOME/npm"

# XDG_STATE_HOME directories
export HISTFILE="$XDG_STATE_HOME/bash_history"
export LESSHISTFILE="$XDG_STATE_HOME/less_history"
export LESSKEY="$XDG_STATE_HOME/less_key"
export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"
export PYTHON_HISTORY="$XDG_STATE_HOME/python_history"
export NODE_REPL_HISTORY="$XDG_STATE_HOME/node/node_repl_history"

# Set the default PATH
export PATH="\
/bin:\
/sbin:\
/usr/bin:\
/usr/sbin:\
/usr/local/bin:\
/usr/local/sbin:\
$XDG_BIN_HOME:\
$NPMUSERBASE/bin:\
$PYTHONUSERBASE/bin"
