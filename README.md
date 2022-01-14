
# auto-ytdl
A small script to automatically find & download new videos from selected youtube channels

## Cache
The channels list is located at ~/.auto-ytdl/channels\_list and has to be filled by the user.  
It's a simple list of urls but urls MUST end with "/videos"  

# Last date download
At the end of each download, ~/.auto-ytdl/cache is updated with today's date.
This file can be considered as a parameter and modified for the next use of the program (but will be overriden when it's over by today's date).
In this new version we use yt-dlp --dateafter option which only supports the YYYYMMDD format.
This implies that videos of the same day will be redownloaded if they are erased from the directory (or auto-ytdl is launched in another directory).
Recommandation is to delete all videos at the beginning of each day.

## TODO
- Add a "clean" option to remove all videos that where downloaded before today but leaving the others or even better: make it so it makes the difference between different times of day - MEDIUM PRIORITY
- Add an option to set a last\_download\_date without having to modify the cache file directly - LOW PRIORITY
Fix: Check youtube-dl's return code and act accordingly  
- Add an error when failing to connect (currently it just behaves like it has properly finished)
