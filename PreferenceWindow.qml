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
                "sectionId": "general",
                "sectionName": "General",
                "subSections": []
            },
            {
                "sectionId": "keyboard",
                "sectionName": "Keyboard",
                "subSections": [
                    {
                        "sectionId": "keyboard_video",
                        "sectionName": "Video",
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
                            text: "Fit video to player"
                            exclusiveGroup: group
                        }
                        DRadio {
                            text: "Fit player to video"
                            exclusiveGroup: group
                        }
                    }
                    Row {
                        spacing: 10                        
                        DRadio {
                            text: "Resize interface to last closed size"
                            exclusiveGroup: group
                        }
                        DRadio {
                            text: "Enter fullscreen mode"
                            exclusiveGroup: group
                        }
                    }
                }
            }

            DCheckBox {
                text: "Clear playlist when opening new file"
            }
            DCheckBox {
                text: "Resume playback after restarting player"
            }
            DCheckBox {
                text: "Continue to next video automatically"
            }
            DCheckBox {
                text: "Show thumbnail when hovering over progress bar"
            }
            DCheckBox {
                text: "allow multiple instance"
            }
            DCheckBox {
                text: "Pause when minimized"
            }
        }

        SectionContent { 
            id: general
            title: "General" 
            sectionId: "general"
            topSpaceHeight: 30

            DCheckBox {
                text: "Enable system popup notification"
            }
            DCheckBox {
                text: "Enable play popup notification"
            }
        }

        SectionContent { title: "Keyboard"; sectionId: ""; topSpaceHeight: 30 }

        SectionContent { 
            id: keyboard_video
            title: "Video" 
            sectionId: "keyboard_video"
            showSep: false
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: "Enable hotkeys"
            }

            HotKeyInputRow {
                title: "Open file"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Open directory"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Pause/Play"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Forward"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Rewind"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Fullscreen"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Previous"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Next"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Increase Volume"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Decrease Volume"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Mute"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Compact mode"
                hotKey: "key"
            }
        }
        SectionContent { 
            id: keyboard_subtitle
            title: "Subtitle" 
            sectionId: "keyboard_subtitle"
            showSep: false
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: "Enable hotkeys"
            }

            HotKeyInputRow {
                title: "Delay-0.5s"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Delay+0.5s"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Loading subtitles"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Increase subtitle scalse"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Decrease subtitle scalse"
                hotKey: "key"
            }
        }
        SectionContent { 
            id: keyboard_other
            title: "Other" 
            sectionId: "keyboard_other"
            showSep: false
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: "Enable hotkeys"
            }

            HotKeyInputRow {
                title: "Increase brightness"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Decrease brightness"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Rotate counterclockwise"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Rotate clockwise"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Take screenshot"
                hotKey: "key"
            }
            HotKeyInputRow {
                title: "Switch audio tracks"
                hotKey: "key"
            }

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