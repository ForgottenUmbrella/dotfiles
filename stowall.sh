#!/bin/zsh
FARM="$(cd "$(dirname "${(%):-%N}")" && pwd)"
for DIR in $FARM/*/; do
    PACKAGE=$(basename $DIR)
    /usr/bin/stow --restow $PACKAGE --target=$HOME
done
