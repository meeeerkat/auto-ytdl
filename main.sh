#!/bin/bash

# Constants
DIR_PATH=${HOME}/.auto-ytdl/
CACHE_PATH=${DIR_PATH}cache

# Global vars
names=()
channels_url=()
last_videos_downloaded_ids=()
channels_nb=0

# Options
verbose=false


# Cache handling
function check_cache_or_create_empty
{
    if [ ! -s "$CACHE_PATH" ];
    then
        echo "The cache at $CACHE_PATH doesn't exists or is empty"
        mkdir "$DIR_PATH" 2> /dev/null
        touch "$CACHE_PATH"
        echo "An empty cache has been created at $CACHE_PATH,
            you need to manually enter the channels urls in it
            following the guidelines specified in the README.md"
        exit 1
    fi
}
function read_cache
{
    while IFS= read -r entry 
    do
        names+=("`echo "$entry" | cut -d , -f 1`")
        channels_url+=(`echo "$entry" | cut -d , -f 2`)
        last_videos_downloaded_ids+=(`echo "$entry" | cut -d , -f 3`)
    done < $CACHE_PATH
    channels_nb=${#names[@]}
}
function write_cache
{
    out=""
    for (( i=0; i<$channels_nb; i++ ));
    do
        out=${out}"${names[$i]}","${channels_url[$i]}","${last_videos_downloaded_ids[$i]}"\\n
    done
    printf "$out" > "$CACHE_PATH"
}



function verbose_name_printing
{
    if [ "$verbose" == true ]
    then
        echo "${names[$1]} done ($(($1 + 1))/$channels_nb)."
    fi
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
    echo "Updating cache (non-setup entries will be automatically setup)"
    for (( i=0; i<$channels_nb; i++ ));
    do
        update_cache_entry_to_last_video $i
        verbose_name_printing $i
    done
    echo "Update completed"
}
# Updates only entries that have no last downloaded video ids
function setup_newly_added_channels
{
    echo "Checking for new channels in cache & setting them up"
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



function download_new_videos_and_update_cache
{
    echo "Searching for new videos & downloading them"
    for (( i=0; i<$channels_nb; i++ ));
    do
        new_last_video_downloaded_id=""
        while IFS= read -r id && [ "$id" != "${last_videos_downloaded_ids[$i]}" ]
        do
            # The first new video id will be the last downloaded in the chronological order of uploads
            if [ ! "$new_last_video_downloaded_id" ];
            then
                new_last_video_downloaded_id="$id"
            fi
            youtube-dl -f best --no-part -- "$id"
        done < <(youtube-dl "${channels_url[$i]}" --get-id 2> /dev/null)
        # If there was a new video, set its id as the last one downloaded
        if [ "$new_last_video_downloaded_id" ];
        then
            last_videos_downloaded_ids[$i]="$new_last_video_downloaded_id"
        fi
        verbose_name_printing $i
    done
    echo "Downloads & cache update completed"
}



function usage
{
    echo "Usage: $0 [-u|-d] [-v]"
    exit 1
}




# MAIN
check_cache_or_create_empty
read_cache

update=false
download=false
while getopts "udv" opt; do
    case $opt in
        u) update=true ;;
        d) download=true ;;
        v) verbose=true ;;
        h) usage ;;
        \?)
            echo "Invalid option: -${OPTARG}."
            usage
            ;;
    esac
done

if [ "$download" == "$update" ]
then
    usage
fi

if [ "$download" == true ]
then
    setup_newly_added_channels
    download_new_videos_and_update_cache
else
    update_cache_to_last_videos
fi

write_cache

