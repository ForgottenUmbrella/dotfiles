#!/bin/sh
# wallplug.sh configuration variables.
# shellcheck disable=SC2034,SC1090,SC2154

# Import definitions ($cache, $config, log).
. "$HOME/.local/lib/wallplug/defs.sh"

# Wallpaper file.
image=$cache/wallplug/image

# Command that modifies wallpaper file and optionally image URL.
command='safebooru_plug touhou pool:scenery_porn'
#command='safebooru_plug "touhou aoha_(twintail)"'
#command='safebooru_plug "touhou akyuun"'
#command='safebooru_plug "touhou landscape"'
#command='safebooru_plug "touhou alcxome"'
#command='safebooru_plug "touhou mikado_(winters)"'
#command='safebooru_plug "touhou asakura_masatoki"'
#command='safebooru_plug "touhou mifuru"'
#command='safebooru_plug "touhou risutaru"'
#command='safebooru_plug "touhou motsuba"'
#command='safebooru_plug "touhou ultimate_asuka"'

# Alpha of colour scheme.
alpha=80
