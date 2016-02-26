/**
 * Copyright (C) 2014 Deepin Technology Co., Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 **/

import QtQuick 2.1
import Deepin.Widgets 1.0

DFileDialog {
    title: dsTr("Please select one file or more")
    folder: _settings.lastOpenedPath || _utils.homeDir
    nameFilters: [ dsTr("Video files") + videoFilter, allFilesFilter]
    selectMultiple: true
    selectExisting: true
    selectFolder: false
    saveMode: false

    property string videoFilter: "(*.3gp *.avi *.f4v *.flv *.mkv *.mov *.mp4
                    *.mpeg *.ogg *.ogv *.rm *.rmvb *.webm *.wmv)"
    property string subtitleFilter: "(*.srt *.ass *.ssa)"
    property string playlistFilter: "(*.dmpl)"
    property string soundTrackFilter: "(*.ac3 *.dts)"
    property string allFilesFilter: dsTr("All files") + "(*)"
    property string state: "open_video_file"

    onStateChanged: {
        switch(state) {
            case "open_video_file":
            title = dsTr("Please select one file or more")
            folder = _settings.lastOpenedPath || _utils.homeDir
            nameFilters = [ dsTr("Video files") + videoFilter, allFilesFilter]
            selectMultiple = true
            selectExisting = true
            defaultFileName = " "
            saveMode = false
            break

            case "open_subtitle_file":
            title = dsTr("Please select one file")
            folder = _settings.lastOpenedPath || _utils.homeDir
            nameFilters = [ dsTr("Subtitle files") + subtitleFilter, allFilesFilter]
            selectMultiple = false
            selectExisting = true
            defaultFileName = " "
            saveMode = false
            break

            case "open_audio_track_file":
            title = dsTr("Please select one file")
            folder = _settings.lastOpenedPath || _utils.homeDir
            nameFilters = [ dsTr("Audio track files") + soundTrackFilter, allFilesFilter]
            selectMultiple = false
            selectExisting = true
            defaultFileName = " "
            saveMode = false
            break

            case "add_playlist_item":
            title = dsTr("Please select one file or more")
            folder = _settings.lastOpenedPath || _utils.homeDir
            nameFilters = [ dsTr("Video files") + videoFilter, allFilesFilter ]
            selectMultiple = true
            selectExisting = true
            defaultFileName = " "
            saveMode = false
            break

            case "import_playlist":
            title = dsTr("Please select one file")
            folder = _settings.lastOpenedPlaylistPath || _utils.homeDir
            nameFilters = [ dsTr("Playlist files") + playlistFilter, allFilesFilter ]
            selectMultiple = false
            selectExisting = true
            defaultFileName = " "
            saveMode = false
            break

            case "export_playlist":
            title = dsTr("Save as")
            folder = _settings.lastOpenedPlaylistPath || _utils.homeDir
            nameFilters = [ dsTr("Playlist files") + playlistFilter, allFilesFilter ]
            selectMultiple = true
            selectExisting = false
            defaultFileName = dsTr("Playlist") + ".dmpl"
            saveMode = true
        }
    }
}
