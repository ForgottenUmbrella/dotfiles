#!/bin/sh
# Plugin to grab images from safebooru.
# The argument to safebooru_plug is a search query.
# shellcheck disable=SC1090,SC2154

# Import definitions ($cache, $config, $url_file, log and die).
. "$HOME/.local/lib/wallplug/defs.sh"
# Import configuration variables ($image).
. "$config/wallplug/config.sh"

# IP to ping to check for network access.
safebooru_test_ip=8.8.8.8

# Return whether the posts.json cache no longer satisifies the tags requested.
safebooru_outdated_tags() {
    tag_string=$1
    shift; tags=$*
    [ "$(python -c "print(all(word in $tag_string for word in '$tags'.split()))")" != 'True' ]
}

# Return whether the given data is of sufficient quality.
safebooru_filter_tags() {
    data=$1
    tag_string=$(echo "$data" | jq '.tag_string')
    [ "$(python -c "print('highres' in $tag_string and 'monochrome' not in $tag_string)")" = 'True' ]
}

# Wait for network access via rudimentary exponential backoff.
safebooru_wait_network() {
    test_ip=$1
    attempts=0
    while ! ping -c1 "$test_ip" > /dev/null; do
        log 'Network temporarily unavailable, sleeping...'
        sleep "$(echo "2^$attempts" | bc)"m
        attempts=$((attempts+1))
    done
}

# Purge posts until one with a valid URL is found, and echo its data.
safebooru_filter_data() {
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
        echo "$data" | jq '.file_url' -e > /dev/null && safebooru_filter_tags "$data"
    do
        :
    done
    echo "$data"
}

# Modify wallpaper file and set image URL from a safebooru.donmai.us search.
safebooru_plug() {
    tags=$*
    posts=$cache/wallplug/posts.json
    safebooru_wait_network "$safebooru_test_ip"
    # Cache image URLs so we don't waste the extra images returned from the API.
    if [ ! -f "$posts" ] || [ "$(wc -m < "$posts")" -le 3 ] ||
           [ "$(jq '.|type' "$posts")" = 'object' ] ||
           safebooru_outdated_tags "$(jq '.[0].tag_string' "$posts")" "$tags"; then
        log 'Downloading posts...'
        curl 'https://safebooru.donmai.us/posts.json' -G \
             --data-urlencode "tags=$tags" --data-urlencode random=true \
             --data-urlencode limit=100 -o "$posts" --create-dirs ||
            die 'Failed to download posts'
    fi
    data=$(safebooru_filter_data "$posts")
    # Download the image.
    log "Downloading image..."
    url=$(echo "$data" | jq '.file_url' -r)
    curl "$url" -o "$image" || die 'Failed to download image'
    # Note where it can be viewed.
    id=$(echo "$data" | jq '.id')
    echo "https://safebooru.donmai.us/posts/$id" > "$url_file"
}
