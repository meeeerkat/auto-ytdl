#!/bin/bash

# Constants
VIDEOS_LIST_URL_FORMAT="https://www.youtube.com/c/%s/videos"
DIR_PATH=${HOME}/.auto-ytdl/
CACHE_PATH=${DIR_PATH}cache

# Global vars
declare -A cache

# Cache handling
function read_cache {
    while IFS= read -r association
    do
        channel=`echo $association | cut -d , -f 1`
        lastVideoDownloadedId=`echo $association | cut -d , -f 2`
        cache[$channel]=$lastVideoDownloadedId
    done < $CACHE_PATH
}
function write_cache {
    echo TODO
}



function download_new_videos {
    for channel in "${!cache[@]}"
    do
        videosListUrl=`printf "$VIDEOS_LIST_URL_FORMAT" "$channel"`
        while IFS= read -r id && [ "$id" != "${cache[$channel]}" ]
        do
            echo "$id"
        done < <(youtube-dl $videosListUrl --get-id)
    done
}



# MAIN
read_cache
download_new_videos



