# zenity open files

This lua script for [mpv media player](https://mpv.io/) will use [Gnome's zenity](https://help.gnome.org/users/zenity/) to open files, subtitles or URLs.

Based on [ntasos](https://github.com/ntasos)'s [kdialog-open-files.lua](https://gist.github.com/ntasos/d1d846abd7d25e4e83a78d22ee067a22).

### Keybindings

+ `CTRL+o`: Add files to the playlist and replace the current playlist.
+ `CTRL+a`: Append selected files to the playlist.
+ `CTRL+s`: Load a subtitle file.
+ `CTRL+u`: Load a URL.

##### TODO

+ `CTRL+SHIFT+o`: Add files in the selected folders to the playlist and replace the current playlist.
+ `CTRL+SHIFT+a`: Append files in the selected folders to the playlist.

<sub>They can be customized at the bottom of the `.lua` file.</sub>


### How to Install

[rtfm](https://mpv.io/manual/master/#script-location)
