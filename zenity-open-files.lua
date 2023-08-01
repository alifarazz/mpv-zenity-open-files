--
-- Use GNOME's zentiy to add files to playlist, subtitles to playing video or open URLs.
-- Based on 'kdialog-open-files'(https://gist.github.com/ntasos/d1d846abd7d25e4e83a78d22ee067a22)
--   which itself is based on 'mpv-open-file-dialog'(https://github.com/rossy/mpv-open-file-dialog).
--
-- Default keybindings:
--      CTRL+o: Add selected files to the playlist and replace the current playlist.
--      CTRL+a: Append selected files to the playlist.
--      CTRL+SHIFT+o: Add files in the selected folders to the playlist and replace the current playlist.
--      CTRL+SHIFT+a: Append files in the selected folders to the playlist.
--      CTRL+s: Load a subtitle file.
--      CTRL+u: Load an URL.
--

utils = require 'mp.utils'

function get_focus_using_xdotool()
    return utils.subprocess({
        args = {'xdotool', 'getwindowfocus'}
    })
end

function invoke_zenity(args)
    -- local focus = get_focus_using_xdotool()
    return utils.subprocess({
        args = {'zenity', unpack(args)},
        cancellable = false,
    })
end

function get_current_directory()
    if mp.get_property("path") == nill then
        return ""
    else
        return utils.split_path(utils.join_path(mp.get_property("working-directory"), mp.get_property("path")))
    end
end

function select_multimedia_files()
    return invoke_zenity({
            '--file-selection',
            '--filename='..get_current_directory(),
            '--title="Select Files"',
            '--window-icon=mpv',
            '--multiple',
            '--separator=\n',
            '--file-filter=Multimedia Files|*.3ga *.egp *.3gpp *.3g2 *.3gp2 *.egpp2 *.m4v *.f4v *.mp2 *.mpeg *.vob *.ogv *.mov *.moov *.qtrv *.tv *.rvx *.webm *.flv *.mkv *.wmp *.wmv *.avi *.avf *.divx *.ogm *.mp4 *.aac *.ac3 *.flac *.mp2 *.mp3 *.m4a *.ogg *.oga *.ra *.rax *.webm *.ape *.mka *.m3u *.m3u8 *.vlc *.wma *.opus *.real *.pls *.tta *.wav'
    })
end
    
function add_files()
    local file_select = select_multimedia_files()
    if (file_select.status ~= 0) then
        return end
    
    local first_file = true
    for filename in string.gmatch(file_select.stdout, '[^\n]+') do
        mp.commandv('loadfile', filename, first_file and 'replace' or 'append')
        first_file = false
    end
end
    
function append_files()
    local playlist_items = 0
    local file_select = select_multimedia_files()
    if (file_select.status ~= 0) then
        return end
    
    for filename in string.gmatch(file_select.stdout, '[^\n]+') do
        if (mp.get_property_number("playlist-count") == 0) then
            mp.commandv('loadfile', filename, 'replace')
        else
            mp.commandv('loadfile', filename, 'append')
        end
        playlist_items = playlist_items + 1
    end
    mp.osd_message("Added "..playlist_items.." file(s) to playlist")
end

function select_folders()
    return invoke_zenity({
            '--file-selection',
            '--directory',
            '--filename='..get_current_directory(),
            '--title="Select Folders"',
            '--window-icon=mpv',
            '--multiple',
            '--separator=\n',
    })
end

function add_folder()
    local folder_select = select_folders()
    if (folder_select.status ~= 0) then
        return end

    -- local first_file = true
    -- for filename in string.gmatch(folder_select.stdout, '[^\n]+') do
    --     mp.commandv('loadfile', filename, first_file and 'replace' or 'append')
    --     first_file = false
    -- end
end

function append_folders()
    local playlist_items = 0
    local folder_select = select_folders()
    if (folder_select.status ~= 0) then
        return end

    -- for filename in string.gmatch(folder_select.stdout, '[^\n]+') do
    --     if (mp.get_property_number("playlist-count") == 0) then
    --         mp.commandv('loadfile', filename, 'replace')
    --     else
    --         mp.commandv('loadfile', filename, 'append')
    --     end
    --     playlist_items = playlist_items + 1
    -- end
    -- mp.osd_message("Added "..playlist_items.." file(s) to playlist")
end

function open_url()
    local url_select = invoke_zenity({
            '--entry',
            '--title=Open URL',
            '--window-icon=mpv',
            '--text=Enter URL:'
    })
    if (url_select.status ~= 0) then
        return end
    
    for filename in string.gmatch(url_select.stdout, '[^\n]+') do
        mp.commandv('loadfile', filename, 'replace')
    end
end

function add_sub()
    local sub_select = invoke_zenity({
            '--file-selection',
            '--title=Select Subtitle',
            '--filename='..get_current_directory(),
            '--window-icon=mpv',
            '--file-filter=Subtitle Files |*.srt *.sub *.ass *.ssa *.mplsub *.txt'
    })
    if (sub_select.status ~= 0) then
        return end
    
    for filename in string.gmatch(sub_select.stdout, '[^\n]+') do
        mp.commandv('sub-add', filename, 'select')
    end
end

mp.register_script_message("zenity-open-files", handlemessage)

mp.add_key_binding("CTRL+o", "add-files-zenity", add_files)
mp.add_key_binding("CTRL+a", "append-files-zenity", append_files)
-- mp.add_key_binding("CTRL+SHIFT+o", "add-folders-zenity", add_folders)
-- mp.add_key_binding("CTRL+SHIFT+a", "append-folders-zenity", append_folders)
mp.add_key_binding("CTRL+u", "open-url-zenity", open_url)
mp.add_key_binding("CTRL+s", "add-subtitle-zenity", add_sub)
