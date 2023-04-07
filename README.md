# VLC playlist parser for Youtube playlists

This is a slight modified version of roland1's [YouTube Channel Feed](https://www.opendesktop.org/p/1412578)

Playlist Parser for Youtube Playlist Feeds of the form:

`https://www.youtube.com/feeds/videos.xml?playlist_id=HERE_GOES_THE_PLAYLIST_ID `

Requires a WORKING youtube playlist parser
(tested with https://raw.githubusercontent.com/videolan/vlc/master/share/lua/playlist/youtube.lua).

INSTALLATION:
Put the youtube_playlist_feed.lua file into (Create directory if it does not exist):
* Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\playlist\
* Windows (current user): %APPDATA%\VLC\lua\playlist\
* Linux (all users): /usr/lib/vlc/lua/playlist/
* Linux (current user): ~/.local/share/vlc/lua/playlist/
* Mac OS X (all users): /Applications/VLC.app/Contents/MacOS/share/lua/playlist/
* Mac OS X (current user): /Users/%your_name%/Library/Application Support/org.videolan.vlc/lua/playlist/


---------------------------------------------------------------------------------
---------------------------------------------------------------------------------


There is a helper extension append_yt_pl_feed.lua to get You started to build up a Playlist Feed.

INSTALLATION:
Put the append_yt_pl_feed.lua file into (Create directory if it does not exist):
* Windows (all users): %ProgramFiles%\VideoLAN\VLC\lua\extensions\
* Windows (current user): %APPDATA%\VLC\lua\extensions\
* Linux (all users): /usr/lib/vlc/lua/extensions/
* Linux (current user): ~/.local/share/vlc/lua/extensions/
* Mac OS X (all users): /Applications/VLC.app/Contents/MacOS/share/lua/extensions/
* Mac OS X (current user): /Users/%your_name%/Library/Application Support/org.videolan.vlc/lua/extensions/
