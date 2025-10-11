#!/bin/sh
# Shell environment setup after login
# Copyright (C) 2015-2016 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>

# This file is extracted from kde-workspace (kdm/kfrontend/genkdmconf.c)
# Copyright (C) 2001-2005 Oswald Buddenhagen <ossi@kde.org>

# Copyright (C) 2024 The Fairy Glade
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See the LICENSE file for more details.

# Note that the respective logout scripts are not sourced.
case $SHELL in
*/bash)
    [ -z "$BASH" ] && exec $SHELL "$0" "$@"
    set +o posix
    [ -f "/etc"/profile ] && . "/etc"/profile
    if [ -f "$HOME"/.bash_profile ]; then
        . "$HOME"/.bash_profile
    elif [ -f "$HOME"/.bash_login ]; then
        . "$HOME"/.bash_login
    elif [ -f "$HOME"/.profile ]; then
        . "$HOME"/.profile
    fi
    ;;
*) # Plain sh, ksh, and anything we do not know.
    [ -f "/etc"/profile ] && . "/etc"/profile
    [ -f "$HOME"/.profile ] && . "$HOME"/.profile
    ;;
esac

exec "$@"
