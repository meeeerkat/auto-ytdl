#!/bin/bash

# Constants
DIR_PATH=${HOME}/.auto-ytdl/
CHANNELS_LIST_PATH=${DIR_PATH}channels_list
CACHE_PATH=${DIR_PATH}cache

# Global vars
last_download_date=""


# Cache handling
function check_cache_or_create_empty
{
    if [ ! -s "$CHANNELS_LIST_PATH" ];
    then
        echo "The cache at $CHANNELS_LIST_PATH doesn't exists or is empty"
        mkdir "$DIR_PATH" 2> /dev/null
        touch "$CHANNELS_LIST_PATH"
        update_cache
        echo "An empty cache has been created at $CHANNELS_LIST_PATH,
            you need to manually enter the channels urls in it
            following the guidelines specified in the README.md"
        exit 1
    fi
}

function read_cache
{
    if [ ! -s "$CACHE_PATH" ];
    then
        update_cache
    fi

    last_download_date=`cat $CACHE_PATH`
}

function update_cache
{
    date -d now "+%Y%m%d" > $CACHE_PATH
}


# MAIN
check_cache_or_create_empty
read_cache

yt-dlp --dateafter "$last_download_date" \
    -f "bestvideo[height<=1080]+bestaudio" \
    --break-on-reject --break-per-input \
    -a "$CHANNELS_LIST_PATH"

update_cache

