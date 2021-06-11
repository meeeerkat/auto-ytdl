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
        echo "youtube-dl ${channelsUrl[$i]} --get-id"
        while IFS= read -r id && [ "$id" != "${lastVideosDownloadedIds[$i]}" ]
        do
            #youtube-dl $id -f best --no-part
            echo $id
        done < <(youtube-dl "${channelsUrl[$i]}" --get-id 2> /dev/null)
    done
}



# MAIN
read_cache
download_new_videos
#update_cache_to_last_videos
#setup_newly_added_channels
write_cache

