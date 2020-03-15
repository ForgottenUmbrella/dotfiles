#!/bin/sh
# Set the wallpaper to something from safebooru.donmai.us using wal and co.
# Dependencies:
# - python-pywal
# - wpgtk-git
# - mantablockscreen
# - jq

# Cache directory.
cache=${XDG_CACHE_HOME:-$HOME/.cache}
# File storing image URL.
url_file=$cache/wallplug/current-url
# Config directory.
config=${XDG_CONFIG_HOME:-$HOME/.config}

# Configuration variables.
# Wallpaper file.
image=$cache/wallplug/image
# Command that modifies wallpaper file and optionally image URL.
#command='safebooru_plug touhou pool:scenery_porn'
#command='safebooru_plug "touhou aoha_(twintail)"'
#command='safebooru_plug "touhou akyuun"'
#command='safebooru_plug "touhou landscape"'
# command='safebooru_plug "touhou alcxome"'
# command='safebooru_plug "touhou mikado_(winters)"'
# command='safebooru_plug "touhou asakura_masatoki"'
# command='safebooru_plug "touhou mifuru"'
command='safebooru_plug "touhou risutaru"'
#command='safebooru_plug "touhou y7j"'
#command='safebooru_plug "touhou motsuba"'
#command='safebooru_plug "touhou ultimate_asuka"'
# Alpha of colour scheme.
alpha=80
# IP to ping to check for network access.
test_ip=8.8.8.8

# Echo help message.
usage() {
    echo \
"Usage: $(basename "$0") [-u] [-i path] [-c command] [-a alpha] [-h]

wallplug.sh - Set the wallpaper using \`wal' and your choice of image source.

Options:
  -u          print the current wallpaper's URL and exit
  -i path     set the wallpaper to a local file (oneshot)
  -c command  set the command to run to fetch the wallpaper (oneshot)
  -a alpha    set the alpha (oneshot)
  -h          show this help message and exit

To permanently change the source for images, modify the script's \`command'
variable.
To permanently change the alpha, modify the script's \`alpha' variable.

The frequency of wallpaper changes is controlled by the systemd timer. Enable
\`wallplug.timer' to set the wallpaper periodically.

Commands are expected to write an image to \$XDG_CACHE_HOME/wallplug/image
and optionally write a source URL to \$XDG_CACHE_HOME/wallplug/current-url.
"
}

# Echo information for user; used to differentiate from pipeline.
log() {
    echo "$@"
}

# Echo error message and exit with last exit code.
die() {
    exit_code=$?
    echo 'Error:' "$@" 1>&2
    exit "$exit_code"
}

# Wait until X DISPLAY is available.
wait_display() {
    while [ -z "$DISPLAY" ]; do
        log 'DISPLAY temporarily unavailable, sleeping...'
        sleep 10
    done
}

# Set the wallpaper, colour scheme and notify change.
set_wallpaper() {
    image=$1
    alpha=$2
    wait_display
    log 'Setting via wal...'
    wal -c; wal -i "$image" -a "$alpha" -e
    # python-pillow-simd is a drop-in replacement for pillow that isn't a
    # drop-in replacement, so anything depending on pillow is broken.
    log 'Setting via wpg...'
    wpg='python -m wpgtk'
    name=$(basename "$image")
    rm "$config/wpg/schemes/"*"$name"* 2>/dev/null; $wpg -a "$image"
    $wpg -n --alpha "$alpha" -s "$name"
    # log 'Setting betterlockscreen...'
    # betterlockscreen -u "$image"
    log 'Setting mantablockscreen...'
    mantablockscreen -i "$image"
    url=$(cat "$url_file" 2>/dev/null || printf '')
    notify-send 'New wallpaper' "$url" -i "$image" -u low
}

# Return whether the posts.json cache no longer satisifies the tags requested.
outdated_tags() {
    tag_string=$1
    shift; tags=$*
    [ "$(python -c "print(all(word in $tag_string for word in '$tags'.split()))")" != 'True' ]
}

# Return whether the given data is of sufficient quality.
filter_tags() {
    data=$1
    tag_string=$(echo "$data" | jq '.tag_string')
    [ "$(python -c "print('highres' in $tag_string and 'monochrome' not in $tag_string)")" = 'True' ]
}

# Wait for network access via rudimentary exponential backoff.
wait_network() {
    test_ip=$1
    attempts=0
    while ! ping -c1 "$test_ip" > /dev/null; do
        log 'Network temporarily unavailable, sleeping...'
        sleep "$(echo "2^$attempts" | bc)"m
        attempts=$((attempts+1))
    done
}

# Purge posts until one with a valid URL is found, and echo its data.
filter_data() {
    posts=$1
    until
        data=$(jq '.[0]' "$posts")
        # Remove the image from the URL cache.
        id=$(echo "$data" | jq '.id')
        temp=$(mktemp)
        jq '.[1:]' "$posts" > "$temp" && mv "$temp" "$posts"
        new_id=$(jq '.[0].id' "$posts")
        [ "$new_id" != "$id" ] ||
            die 'Failed to remove image from URL cache'
        # Check URL is not null and data is of sufficient quality.
        echo "$data" | jq '.file_url' -e > /dev/null && filter_tags "$data"
    do
        :
    done
    echo "$data"
}

# Modify wallpaper file and set image URL from a safebooru.donmai.us search.
safebooru_plug() {
    tags=$*
    posts=$cache/wallplug/posts.json
    wait_network "$test_ip"
    # Cache image URLs so we don't waste the extra images returned from the API.
    if [ ! -f "$posts" ] || [ "$(wc -m < "$posts")" -le 3 ] ||
           [ "$(jq '.|type' "$posts")" = 'object' ] ||
           outdated_tags "$(jq '.[0].tag_string' "$posts")" "$tags"; then
        log 'Downloading posts...'
        curl 'https://safebooru.donmai.us/posts.json' -G \
             --data-urlencode "tags=$tags" --data-urlencode random=true \
             -o "$posts" --create-dirs || die 'Failed to download posts'
    fi
    data=$(filter_data "$posts")
    # Download the image.
    log "Downloading image..."
    url=$(echo "$data" | jq '.file_url' -r)
    curl "$url" -o "$image" || die 'Failed to download image'
    # Note where it can be viewed.
    id=$(echo "$data" | jq '.id')
    echo "https://safebooru.donmai.us/posts/$id" > "$url_file"
}

while getopts ':ui:c:a:h?' option; do
    case "$option" in
        u)
            cat "$url_file"
            exit
            ;;
        i)
            image="$OPTARG"
            command=''
            ;;
        c)
            command="$OPTARG"
            ;;
        a)
            alpha="$OPTARG"
            ;;
        \? | h | *)
            usage
            exit
            ;;
    esac
done
eval "$command"
set_wallpaper "$image" "$alpha"
