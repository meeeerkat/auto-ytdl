
# auto-ytdl
A small script to automatically find & download new videos from selected youtube channels

## Cache
The cache is located at ~/.auto-ytdl/cache and has to be filled by the user.  
It's a .csv like format with the separator being a comma (',') and each entry MUST follow the pattern below:  
name(only for the user reading the file),channelUrl(ending with /videos to get last uploaded videos ids first),lastVideoDownloadedId(setup&used only by the program)  
IMPORTANT: urls MUST end with "/videos"  

## TODO
- Sending SIGINT (Ctrl+C) to the program while downloading a video only stops youtube-dl's current execution but the last downloaded video id is still updated
Fix: Check youtube-dl's return code and act accordingly  
- Add an error when failing to connect (currently it just behaves like it has properly finished)
