import QtQuick 2.1
import QtQuick.Controls 1.1
import Deepin.Widgets 1.0

DPreferenceWindow {
    width: 560
    height: 480

    content: DPreferenceView {
        id: preference_view
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        sectionListWidth:  100
        layer.enabled: true
        
        sections: [
            {
                "sectionId": "playback",
                "sectionName": "Playback",
                "subSections": []
            },
            {
                "sectionId": "keyboard",
                "sectionName": "Keyboard",
                "subSections": [
                    {
                        "sectionId": "keyboard_playback",
                        "sectionName": "Playback",
                        "subSections": []
                    },                    
                    {
                        "sectionId": "keyboard_frame_sound",
                        "sectionName": "Frame/Sound",
                        "subSections": []
                    },                    
                    {
                        "sectionId": "keyboard_files",
                        "sectionName": "Files",
                        "subSections": []
                    },
                    {
                        "sectionId": "keyboard_subtitle",
                        "sectionName": "Subtitle",
                        "subSections": []
                    },
                    {
                        "sectionId": "keyboard_other",
                        "sectionName": "Other",
                        "subSections": []
                    },
                ]
            },
            {
                "sectionId": "subtitles",
                "sectionName": "Subtitles",
                "subSections": []
            },
            {
                "sectionId": "screenshot",
                "sectionName": "Screenshot",
                "subSections": []
            },
            {
                "sectionId": "about",
                "sectionName": "About",
                "subSections": []
            }
        ]

        SectionContent { 
            id: playback
            title: "Playback" 
            sectionId: "playback"

            DGroupBox {
                /* title: "On opening video:" */
                tTitle: "On opening video:"
                ExclusiveGroup { id: group }
                Column {
                    width: playback.width
                    Row {
                        spacing: 10
                        DRadio {
                            text: dsTr("Fit video to player")
                            exclusiveGroup: group
                            checked: config.playerAdjustType == "ADJUST_TYPE_VIDEO_WINDOW"
                            onClicked: if(checked) { config.playerAdjustType = "ADJUST_TYPE_VIDEO_WINDOW" }
                        }
                        DRadio {
                            text: dsTr("Fit player to video")
                            exclusiveGroup: group
                            checked: config.playerAdjustType == "ADJUST_TYPE_WINDOW_VIDEO"
                            onClicked: if(checked) { config.playerAdjustType = "ADJUST_TYPE_WINDOW_VIDEO" }
                        }
                    }
                    Row {
                        spacing: 10                        
                        DRadio {
                            text: dsTr("Resize interface to last closed size")
                            exclusiveGroup: group
                            checked: config.playerAdjustType == "ADJUST_TYPE_LAST_TIME"
                            onClicked: if(checked) { config.playerAdjustType = "ADJUST_TYPE_LAST_TIME" }
                        }
                        DRadio {
                            text: dsTr("Enter fullscreen mode")
                            checked: config.playerAdjustType == "ADJUST_TYPE_FULLSCREEN"
                            exclusiveGroup: group
                            onClicked: if(checked) { config.playerAdjustType = "ADJUST_TYPE_FULLSCREEN" }
                        }
                    }
                }
            }

            DCheckBox {
                text: dsTr("Clear playlist when opening new file")
                checked: config.playerCleanPlaylistOnOpenNewFile
                onClicked: config.playerCleanPlaylistOnOpenNewFile = checked
            }
            DCheckBox {
                text: dsTr("Resume playback after restarting player")
                checked: config.playerAutoPlayFromLast
                onClicked: config.playerAutoPlayFromLast = checked
            }
            DCheckBox {
                text: dsTr("Continue to next video automatically")
                checked: config.playerAutoPlaySeries
                onClicked: config.playerAutoPlaySeries = checked
            }
            DCheckBox {
                text: "Show thumbnail when hovering over progress bar"
                checked: config.playerShowPreview
                onClicked: config.playerShowPreview = checked
            }
            DCheckBox {
                text: "allow multiple instance"
            }
            DCheckBox {
                text: "Pause when minimized"
                checked: config.playerPauseOnMinimized
                onClicked: config.playerPauseOnMinimized = checked
            }
            DCheckBox {
                text: "Enable system popup notification"
                checked: config.playerNotificationsEnabled
                onClicked: config.playerNotificationsEnabled = checked
            }
        }

        SectionContent { title: "Keyboard"; sectionId: ""; topSpaceHeight: 30 }

        SectionContent { 
            id: keyboard_playback
            title: "Playback" 
            sectionId: "keyboard_playback"
            showSep: false
            topSpaceHeight: 5
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: "Enable hotkeys"
                checked: config.hotkeysPlayHotkeyEnabled
                onClicked: config.hotkeysPlayHotkeyEnabled = checked
            }
            HotKeyInputRow {
                title: "Pause/Play"
                hotKey: config.hotkeysPlayTogglePlay
                onHotkeySet: config.hotkeysPlayTogglePlay = hotkey
            }
            HotKeyInputRow {
                title: "Forward"
                hotKey: config.hotkeysPlayForward
                onHotkeySet: config.hotkeysPlayForward = hotkey
            }
            HotKeyInputRow {
                title: "Rewind"
                hotKey: config.hotkeysPlayBackward
                onHotkeySet: config.hotkeysPlayBackward = hotkey
            }
            HotKeyInputRow {
                title: "Fullscreen"
                hotKey: config.hotkeysPlayToggleFullscreen
            }
            HotKeyInputRow {
                title: "Speed up"
                hotKey: config.hotkeysPlaySpeedUp
            }
            HotKeyInputRow {
                title: "Slow down"
                hotKey: config.hotkeysPlaySlowDown
            }
        }
        SectionContent { 
            id: keyboard_frame_sound
            title: "Frame/Sound" 
            sectionId: "keyboard_frame_sound"
            showSep: false
            topSpaceHeight: 5
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: "Enable hotkeys"
                checked: config.hotkeysFrameSoundHotkeyEnabled
                onClicked: config.hotkeysFrameSoundHotkeyEnabled = checked
            }

            HotKeyInputRow {
                title: "Mini Mode"
                hotKey: config.hotkeysFrameSoundMiniMode
            }
            HotKeyInputRow {
                title: "Rotate counterclockwise"
                hotKey: config.hotkeysFrameSoundRotateAnticlockwise
            }
            HotKeyInputRow {
                title: "Rotate clockwise"
                hotKey: config.hotkeysFrameSoundRotateClockwise
            }
            HotKeyInputRow {
                title: "Increase Volume"
                hotKey: config.hotkeysFrameSoundIncreaseVolume
            }
            HotKeyInputRow {
                title: "Decrease Volume"
                hotKey: config.hotkeysFrameSoundDecreaseVolume
            }
            HotKeyInputRow {
                title: "Mute"
                hotKey: config.hotkeysFrameSoundToggleMute
            }
        }
        SectionContent { 
            id: keyboard_files
            title: "Files" 
            sectionId: "keyboard_files"
            showSep: false
            topSpaceHeight: 5
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: "Enable hotkeys"
                checked: config.hotkeysFilesHotkeyEnabled
                onClicked: config.hotkeysFilesHotkeyEnabled = checked                
            }

            HotKeyInputRow {
                title: "Open file"
                hotKey: config.hotkeysFilesOpenFile
            }
            HotKeyInputRow {
                title: "Open Previous"
                hotKey: config.hotkeysFilesPlayPrevious
            }
            HotKeyInputRow {
                title: "Open Next"
                hotKey: config.hotkeysFilesPlayNext
            }
        }
        SectionContent { 
            id: keyboard_subtitle
            title: "Subtitle" 
            sectionId: "keyboard_subtitle"
            showSep: false
            topSpaceHeight: 5
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: "Enable hotkeys"
                checked: config.hotkeysSubtitlesHotkeyEnabled
                onClicked: config.hotkeysSubtitlesHotkeyEnabled = checked                
            }

            HotKeyInputRow {
                title: "Delay-0.5s"
                hotKey: config.hotkeysSubtitlesSubtitleForward
            }
            HotKeyInputRow {
                title: "Delay+0.5s"
                hotKey: config.hotkeysSubtitlesSubtitleBackward
            }
            HotKeyInputRow {
                title: "Subtitle move up"
                hotKey: config.hotkeysSubtitlesSubtitleMoveUp
            }
            HotKeyInputRow {
                title: "Subtitle move down"
                hotKey: config.hotkeysSubtitlesSubtitleMoveDown
            }
        }
        SectionContent { 
            id: keyboard_other
            title: "Other" 
            sectionId: "keyboard_other"
            showSep: false
            topSpaceHeight: 5
            anchors.left: parent.left
            anchors.leftMargin: 5

            ComboBoxRow {
                title: "Left Click"
            }
            ComboBoxRow {
                title: "Double Click"
            }
            ComboBoxRow {
                title: "Scroll"
            }

        }
        SectionContent { 
            id: subtitles
            title: "Subtitles" 
            sectionId: "subtitles"
            topSpaceHeight: 30

            DCheckBox {
                text: "Load subtitles automatically"
            }

            FileInputRow {
                title: "Subtitle directory:"
            }
        }
        SectionContent { 
            id: screenshot
            title: "Screenshot" 
            sectionId: "screenshot"
            topSpaceHeight: 30
        }
        SectionContent { 
            id: about
            title: "About" 
            sectionId: "about"
            topSpaceHeight: 30
        }
    }
}