import QtQuick 2.1
import QtQuick.Controls 1.1
import Deepin.Widgets 1.0

DPreferenceWindow {
    id: window
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
                "sectionName": dsTr("Playback"),
                "subSections": []
            },
            {
                "sectionId": "keyboard",
                "sectionName": dsTr("Keyboard"),
                "subSections": [
                    {
                        "sectionId": "keyboard_playback",
                        "sectionName": dsTr("Playback"),
                        "subSections": []
                    },                    
                    {
                        "sectionId": "keyboard_frame_sound",
                        "sectionName": dsTr("Frame/Sound"),
                        "subSections": []
                    },                    
                    {
                        "sectionId": "keyboard_files",
                        "sectionName": dsTr("Files"),
                        "subSections": []
                    },
                    {
                        "sectionId": "keyboard_subtitle",
                        "sectionName": dsTr("Subtitle"),
                        "subSections": []
                    },
                    {
                        "sectionId": "keyboard_other",
                        "sectionName": dsTr("Other"),
                        "subSections": []
                    },
                ]
            },
            {
                "sectionId": "subtitles",
                "sectionName": dsTr("Subtitles"),
                "subSections": []
            },
            // {
            //     "sectionId": "screenshot",
            //     "sectionName": "Screenshot",
            //     "subSections": []
            // },
            {
                "sectionId": "about",
                "sectionName": dsTr("About"),
                "subSections": []
            }
        ]

        SectionContent { 
            id: playback
            title: dsTr("Playback")
            sectionId: "playback"
            bottomSpaceHeight: 10

            DCheckBox {
                text: dsTr("Enter fullscreen on opening file")
                checked: config.playerFullscreenOnOpenFile
                onClicked: config.playerFullscreenOnOpenFile = checked
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
                text: dsTr("Show thumbnail when hovering over progress bar")
                checked: config.playerShowPreview
                onClicked: config.playerShowPreview = checked
            }
            DCheckBox {
                text: dsTr("allow multiple instance")
            }
            DCheckBox {
                text: dsTr("Pause when minimized")
                checked: config.playerPauseOnMinimized
                onClicked: config.playerPauseOnMinimized = checked
            }
            DCheckBox {
                text: dsTr("Enable system popup notification")
                checked: config.playerNotificationsEnabled
                onClicked: config.playerNotificationsEnabled = checked
            }
            
            SpinnerRow {
                title: dsTr("Forward/Rewind Step")
                min: 1.0
                max: 30.0
                text: config.playerForwardRewindStep
                anchors.topMargin: 20

                onValueChanged: config.playerForwardRewindStep = value + 0.0
            }
        }

        SectionContent { title: "Keyboard"; sectionId: ""; topSpaceHeight: 30; bottomSpaceHeight: 10 }

        SectionContent { 
            id: keyboard_playback
            title: dsTr("Playback")
            sectionId: "keyboard_playback"
            showSep: false
            topSpaceHeight: 5
            bottomSpaceHeight: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: dsTr("Enable hotkeys")
                checked: config.hotkeysPlayHotkeyEnabled
                onClicked: config.hotkeysPlayHotkeyEnabled = checked
            }
            HotKeyInputRow {
                title: dsTr("Pause/Play")
                hotKey: config.hotkeysPlayTogglePlay
                onHotkeySet: config.hotkeysPlayTogglePlay = hotkey
            }
            HotKeyInputRow {
                title: dsTr("Forward")
                hotKey: config.hotkeysPlayForward
                onHotkeySet: config.hotkeysPlayForward = hotkey
            }
            HotKeyInputRow {
                title: dsTr("Rewind")
                hotKey: config.hotkeysPlayBackward
                onHotkeySet: config.hotkeysPlayBackward = hotkey
            }
            HotKeyInputRow {
                title: dsTr("Fullscreen")
                hotKey: config.hotkeysPlayToggleFullscreen
            }
            HotKeyInputRow {
                title: dsTr("Speed up")
                hotKey: config.hotkeysPlaySpeedUp
            }
            HotKeyInputRow {
                title: dsTr("Slow down")
                hotKey: config.hotkeysPlaySlowDown
            }
        }
        SectionContent { 
            id: keyboard_frame_sound
            title: "Frame/Sound" 
            sectionId: "keyboard_frame_sound"
            showSep: false
            topSpaceHeight: 10
            bottomSpaceHeight: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: dsTr("Enable hotkeys")
                checked: config.hotkeysFrameSoundHotkeyEnabled
                onClicked: config.hotkeysFrameSoundHotkeyEnabled = checked
            }

            HotKeyInputRow {
                title: dsTr("Mini Mode")
                hotKey: config.hotkeysFrameSoundToggleMiniMode
            }
            HotKeyInputRow {
                title: dsTr("Rotate counterclockwise")
                hotKey: config.hotkeysFrameSoundRotateAnticlockwise
            }
            HotKeyInputRow {
                title: dsTr("Rotate clockwise")
                hotKey: config.hotkeysFrameSoundRotateClockwise
            }
            HotKeyInputRow {
                title: dsTr("Increase Volume")
                hotKey: config.hotkeysFrameSoundIncreaseVolume
            }
            HotKeyInputRow {
                title: dsTr("Decrease Volume")
                hotKey: config.hotkeysFrameSoundDecreaseVolume
            }
            HotKeyInputRow {
                title: dsTr("Mute")
                hotKey: config.hotkeysFrameSoundToggleMute
            }
        }
        SectionContent { 
            id: keyboard_files
            title: dsTr("Files")
            sectionId: "keyboard_files"
            showSep: false
            topSpaceHeight: 10
            bottomSpaceHeight: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: dsTr("Enable hotkeys")
                checked: config.hotkeysFilesHotkeyEnabled
                onClicked: config.hotkeysFilesHotkeyEnabled = checked                
            }

            HotKeyInputRow {
                title: dsTr("Open file")
                hotKey: config.hotkeysFilesOpenFile
            }
            HotKeyInputRow {
                title: dsTr("Open Previous")
                hotKey: config.hotkeysFilesPlayPrevious
            }
            HotKeyInputRow {
                title: dsTr("Open Next")
                hotKey: config.hotkeysFilesPlayNext
            }
        }
        SectionContent { 
            id: keyboard_subtitle
            title: dsTr("Subtitle")
            sectionId: "keyboard_subtitle"
            showSep: false
            topSpaceHeight: 10
            bottomSpaceHeight: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: dsTr("Enable hotkeys")
                checked: config.hotkeysSubtitlesHotkeyEnabled
                onClicked: config.hotkeysSubtitlesHotkeyEnabled = checked                
            }

            HotKeyInputRow {
                title: dsTr("Delay-0.5s")
                hotKey: config.hotkeysSubtitlesSubtitleForward
            }
            HotKeyInputRow {
                title: dsTr("Delay+0.5s")
                hotKey: config.hotkeysSubtitlesSubtitleBackward
            }
            HotKeyInputRow {
                title: dsTr("Subtitle move up")
                hotKey: config.hotkeysSubtitlesSubtitleMoveUp
            }
            HotKeyInputRow {
                title: dsTr("Subtitle move down")
                hotKey: config.hotkeysSubtitlesSubtitleMoveDown
            }
        }
        SectionContent { 
            id: keyboard_other
            title: dsTr("Other")
            sectionId: "keyboard_other"
            showSep: false
            topSpaceHeight: 10
            bottomSpaceHeight: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            ComboBoxRow {
                title: dsTr("Left Click")
                input.parentWindow: window
                input.selectIndex: config.othersLeftClick ? 0 : 1
                input.menu.labels: [dsTr("Pause/Play"), dsTr("Disabled")]

                onMenuSelect: config.othersLeftClick = index == 0
            }
            ComboBoxRow {
                title: dsTr("Double Click")
                input.parentWindow: window
                input.selectIndex: config.othersDoubleClick ? 0 : 1
                input.menu.labels: [dsTr("Fullscreen"), dsTr("Disabled")]

                onMenuSelect: config.othersDoubleClick = index == 0
            }
            ComboBoxRow {
                title: dsTr("Scroll")
                input.parentWindow: window
                input.selectIndex: config.othersWheel ? 0 : 1
                input.menu.labels: [dsTr("Volume"), dsTr("Disabled")]

                onMenuSelect: config.othersWheel = index == 0
            }

        }
        SectionContent { 
            id: subtitles
            title: dsTr("Subtitles")
            sectionId: "subtitles"
            topSpaceHeight: 30
            bottomSpaceHeight: 10

            DCheckBox {
                text: "Load subtitles automatically"
            }

            ComboBoxRow {
                title: dsTr("Font")
                input.parentWindow: window
                input.selectIndex: config.subtitleFontFamily ? Qt.fontFamilies().indexOf(config.subtitleFontFamily) 
                                                            : Qt.fontFamilies().indexOf(getSystemFontFamily())
                input.menu.labels: Qt.fontFamilies()

                onMenuSelect: config.subtitleFontFamily = Qt.fontFamilies()[index]
            }

            SpinnerRow {
                title: dsTr("Size")
                min: 10
                max: 30
                text: config.subtitleFontSize

                onValueChanged: config.subtitleFontSize = value
            }

            SpinnerRow {
                title: dsTr("Border Width")
                min: 0
                max: 6
                text: config.subtitleFontBorderSize

                onValueChanged: config.subtitleFontBorderSize = value + 0.0
            }

            SliderRow {
                title: dsTr("Position")
                min: 0
                max: 1
                init: config.subtitleVerticalPosition
                floatNumber: 2
                leftRuler: dsTr("Bottom")
                rightRuler: dsTr("Top")

                onValueChanged: config.subtitleVerticalPosition = value
            }

            // FileInputRow {
            //     title: "Subtitle directory:"
            // }
        }
        // SectionContent { 
        //     id: screenshot
        //     title: "Screenshot" 
        //     sectionId: "screenshot"
        //     topSpaceHeight: 30
        // }
        AboutSection {}
    }
}