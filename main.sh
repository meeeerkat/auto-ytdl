#!/bin/bash

# Constants
DIR_PATH=${HOME}/.auto-ytdl/
CACHE_PATH=${DIR_PATH}cache

# Global vars
names=()
channels_url=()
last_videos_downloaded_ids=()
channels_nb=0


# Cache handling
function read_cache
{
    while IFS= read -r entry 
    do
        names+=(`echo "$entry" | cut -d , -f 1`)
        channels_url+=(`echo "$entry" | cut -d , -f 2`)
        last_videos_downloaded_ids+=("`echo "$entry" | cut -d , -f 3`")
    done < $CACHE_PATH
    channels_nb=${#names[@]}
}
function write_cache
{
    out=""
    for (( i=0; i<$channels_nb; i++ ));
    do
        out=${out}${names[$i]},${channels_url[$i]},${last_videos_downloaded_ids[$i]}\\n
    done
    printf $out > "$CACHE_PATH"
}




# First argument is the entry's index
function update_cache_entry_to_last_video
{
    lastVideoId=`youtube-dl "${channels_url[$1]}" --get-id --playlist-end 1`
    last_videos_downloaded_ids[$1]="$lastVideoId"
}
# Updates all entries
function update_cache_to_last_videos
{
    for (( i=0; i<$channels_nb; i++ ));
    do
        update_cache_entry_to_last_video $i
    done
}
# Updates only entries that have no last downloaded video ids
function setup_newly_added_channels
{
    for (( i=0; i<$channels_nb; i++ ));
    do
        if [ ! "${last_videos_downloaded_ids[$i]}" ];
        then
            update_cache_entry_to_last_video $i
        fi
    done
}



function download_new_videos_and_update_cache
{
    for (( i=0; i<$channels_nb; i++ ));
    do
        new_last_video_downloaded_id="$id"
        while IFS= read -r id && [ "$id" != "${last_videos_downloaded_ids[$i]}" ]
        do
            youtube-dl "$id" -f best --no-part
            new_last_video_downloaded_id="$id"
        done < <(youtube-dl "${channels_url[$i]}" --get-id 2> /dev/null)
        last_videos_downloaded_ids[$i]="$new_last_video_downloaded_id"
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
    download_new_videos_and_update_cache
elif [ $1 == u ]
then
    update_cache_to_last_videos
fi

write_cache

