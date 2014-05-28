import QtQuick 2.1
import QtQuick.Controls 1.1
import Deepin.Widgets 1.0

DPreferenceWindow {
    width: 560
    height: 480

    content: DPreferenceView {
        id: preference_view
        sectionListWidth:  100
        
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

            GroupBox {
                title: "On opening video:"
                ExclusiveGroup { id: group }
                Column {
                    width: playback.width
                    Row {
                        RadioButton {
                            text: "Fit video to player"
                            exclusiveGroup: group
                        }
                        RadioButton {
                            text: "Fit player to video"
                            exclusiveGroup: group
                        }
                    }
                    Row {
                        RadioButton {
                            text: "Resize interface to last closed size"
                            exclusiveGroup: group
                        }
                        RadioButton {
                            text: "Enter fullscreen mode"
                            exclusiveGroup: group
                        }
                    }
                }
            }
            Column {
                width: playback.width

                CheckBox {
                    text: "Clear playlist when opening new file"
                }
                CheckBox {
                    text: "Resume playback after restarting player"
                }
                CheckBox {
                    text: "Continue to next video automatically"
                }
                CheckBox {
                    text: "Show thumbnail when hovering over progress bar"
                }
                CheckBox {
                    text: "allow multiple instance"
                }
                CheckBox {
                    text: "Pause when minimized"
                }
            }
        }

        SectionContent { 
            id: general
            title: "General" 
            sectionId: "general"

            Column {
                width: general.width

                CheckBox {
                    text: "Enable system popup notification"
                }
                CheckBox {
                    text: "Enable play popup notification"
                }
            }
        }

        SectionContent { 
            id: keyboard_video
            title: "Video" 
            sectionId: "keyboard_video"

            HotKeyInput{}
            HotKeyInput{}
        }
        SectionContent { 
            id: keyboard_subtitle
            title: "Subtitle" 
            sectionId: "keyboard_subtitle"

        }
        SectionContent { 
            id: keyboard_other
            title: "Other" 
            sectionId: "keyboard_other"

        }
        SectionContent { 
            id: subtitles
            title: "Subtitles" 
            sectionId: "subtitles"

        }
        SectionContent { 
            id: screenshot
            title: "Screenshot" 
            sectionId: "screenshot"

        }
        SectionContent { 
            id: about
            title: "About" 
            sectionId: "about"

        }
    }
}