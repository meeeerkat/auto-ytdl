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
    echo "Updating all channels last downloaded videos to last uploaded video"
    for (( i=0; i<$channels_nb; i++ ));
    do
        update_cache_entry_to_last_video $i
    done
    echo "Update completed"
}
# Updates only entries that have no last downloaded video ids
function setup_newly_added_channels
{
    echo "Checking for new channels & setting them up"
    for (( i=0; i<$channels_nb; i++ ));
    do
        if [ ! "${last_videos_downloaded_ids[$i]}" ];
        then
            update_cache_entry_to_last_video $i
            echo "${names[$i]} last downloaded video was set to last uploaded"
        fi
    done
    echo "Setup completed"
}



function download_new_videos
{
    echo "Searching for new videos & downloading them"
    for (( i=0; i<$channels_nb; i++ ));
    do
        while IFS= read -r id && [ "$id" != "${last_videos_downloaded_ids[$i]}" ]
        do
            youtube-dl "$id" -f best --no-part
        done < <(youtube-dl "${channels_url[$i]}" --get-id 2> /dev/null)
    done
    echo "Downloads completed"
}



function usage
{
    echo "Usage: $0 [ud]..."
    exit 1
}




# MAIN

read_cache

for op in $@
do
    if [ $op == d ]
    then
        setup_newly_added_channels
        download_new_videos
    elif [ $op == u ]
    then
        update_cache_to_last_videos
    else
        usage
    fi
done

write_cache

