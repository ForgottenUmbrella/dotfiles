#!/bin/sh
# Set the wallpaper to something from safebooru.donmai.us using wal and co.
# Dependencies:
# - python-pywal
# - wpgtk-git
# - betterlockscreen
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
command='safebooru_plug "touhou landscape"'
#command='safebooru_plug "touhou alcxome"'
#command='safebooru_plug "touhou mikado_(winters)"'
#command='safebooru_plug "touhou asakura_masatoki"'
# Alpha of colour scheme.
alpha=80
# Maximum number of retries for network access.
max_retries=4
# IP to ping to check for network access.
test_ip=8.8.8.8

# Print help message.
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

# Return whether X DISPLAY is available in at most $1 * 10 seconds.
wait_display() {
    max_retries=$1
    attempts=0
    while [ "$attempts" -lt "$max_retries" ] && [ -z "$DISPLAY" ]; do
        log 'DISPLAY temporarily unavailable, sleeping...'
        sleep 10
        attempts=$((attempts+1))
    done
    if [ "$attempts" -eq "$max_retries" ]; then
        [ -z "$DISPLAY" ]
    fi
}

# Set the wallpaper, colour scheme and notify change.
set_wallpaper() {
    image=$1
    alpha=$2
    wait_display "$max_retries" || die 'X DISPLAY unavailable'
    log 'Setting via wal...'
    wal -c; wal -i "$image" -a "$alpha" -e
    # python-pillow-simd is a drop-in replacement for pillow that isn't a
    # drop-in replacement, so anything depending on pillow is broken.
    log 'Setting via wpg...'
    wpg='python -m wpgtk'
    name=$(basename "$image")
    rm "$config/wpg/schemes/"*"$name"*; $wpg -a "$image"
    $wpg -n --alpha "$alpha" -s "$name"
    log 'Setting betterlockscreen...'
    betterlockscreen -u "$image"
    url=$(cat "$url_file" 2>/dev/null || printf '')
    notify-send 'New wallpaper' "$url" -i "$image" -u low
}

# Return whether the posts.json cache no longer satisifies the tags requested.
outdated_tags() {
    tag_string=$1
    shift; tags=$*
    [ "$(python -c "print(all(word in $tag_string for word in '$tags'.split()))")" != 'True' ]
}

# Return whether there is network access via rudimentary exponential backoff.
# Maximum time to wait is 2^$2 - 1 minutes.
wait_network() {
    test_ip=$1
    max_retries=$2
    attempts=0
    while [ "$attempts" -lt "$max_retries" ] &&
              ! ping -c1 "$test_ip" > /dev/null; do
        log 'Network temporarily unavailable, sleeping...'
        sleep "$(echo "2^$attempts" | bc)"m
        attempts=$((attempts+1))
    done
    if [ "$attempts" -eq "$max_retries" ]; then
        ping -c1 "$test_ip" > /dev/null
    fi
}

# Modify wallpaper file and set image URL from a safebooru.donmai.us search.
safebooru_plug() {
    tags=$*
    posts=$cache/wallplug/posts.json
    wait_network "$test_ip" "$max_retries" || die 'Network unavailable'
    # Cache image URLs so we don't waste the extra images returned from the API.
    if [ ! -f "$posts" ] || [ "$(wc -m < "$posts")" -le 3 ] ||
           [ "$(jq '.|type' "$posts")" = 'object' ] ||
           outdated_tags "$(jq '.[0].tag_string' "$posts")" "$tags"; then
        log 'Downloading posts...'
        curl 'https://safebooru.donmai.us/posts.json' -G \
             --data-urlencode "tags=$tags" --data-urlencode random=true \
             -o "$posts" --create-dirs || die 'Failed to download posts'
    fi
    data=$(jq '.[0]' "$posts")
    # Download the image.
    log "Downloading image..."
    url=$(echo "$data" | jq '.file_url' -r)
    curl "$url" -o "$image" || die 'Failed to download image'
    # Note where it can be viewed.
    id=$(echo "$data" | jq '.id')
    echo "https://safebooru.donmai.us/posts/$id" > "$url_file"
    # Remove the image from our URL cache.
    temp=$(mktemp)
    jq '.[1:]' "$posts" > "$temp" && mv "$temp" "$posts"
    new_id=$(jq '.[0].id' "$posts")
    [ "$new_id" != "$id" ] ||
        die 'Failed to remove image from cache'
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
