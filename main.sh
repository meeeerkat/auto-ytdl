#!/bin/bash

# Constants
channelUrl_URL_FORMAT="https://www.youtube.com/user/%s"
DIR_PATH=${HOME}/.auto-ytdl/
CACHE_PATH=${DIR_PATH}cache

# Global vars
names=()
channelsUrl=()
lastVideosDownloadedIds=()
channelsNb=0


# Cache handling
function read_cache
{
    while IFS= read -r entry 
    do
        names+=(`echo "$entry" | cut -d , -f 1`)
        channelsUrl+=(`echo "$entry" | cut -d , -f 2`)
        lastVideosDownloadedIds+=("`echo "$entry" | cut -d , -f 3`")
    done < $CACHE_PATH
    channelsNb=${#names[@]}
}
function write_cache
{
    out=""
    for (( i=0; i<$channelsNb; i++ ));
    do
        out=${out}${names[$i]},${channelsUrl[$i]},${lastVideosDownloadedIds[$i]}\\n
    done
    printf $out > "$CACHE_PATH"
}




# First argument is the entry's index
function update_cache_entry_to_last_video
{
    lastVideoId=`youtube-dl "${channelsUrl[$1]}" --get-id --playlist-end 1`
    lastVideosDownloadedIds[$1]="$lastVideoId"
}
# Updates all entries
function update_cache_to_last_videos
{
    for (( i=0; i<$channelsNb; i++ ));
    do
        update_cache_entry_to_last_video $i
    done
}
# Updates only entries that have no last downloaded video ids
function setup_newly_added_channels
{
    for (( i=0; i<$channelsNb; i++ ));
    do
        if [ ! "${lastVideosDownloadedIds[$i]}" ];
        then
            update_cache_entry_to_last_video $i
        fi
    done
}



function download_new_videos
{
    for (( i=0; i<$channelsNb; i++ ));
    do
        while IFS= read -r id && [ "$id" != "${lastVideosDownloadedIds[$i]}" ]
        do
            youtube-dl "$id" -f best --no-part
        done < <(youtube-dl "${channelsUrl[$i]}" --get-id 2> /dev/null)
        lastVideosDownloadedIds[$i]="$id"
    done
}



function test_args
{
    if [ $# -ne 1 ] || ([ $1 != d ] && [ $1 != u ])
    then
        echo "Usage: $0 [ud]"
        exit 1
    fi
}




# MAIN
test_args $@

read_cache

if [ $1 == d ]
then
    setup_newly_added_channels
    download_new_videos
elif [ $1 == u ]
then
    update_cache_to_last_videos
fi

write_cache

