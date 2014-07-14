import QtQuick 2.1
import QtQuick.Controls 1.1
import Deepin.Widgets 1.0

DPreferenceWindow {
    id: window
    width: 560
    height: 480
    flags: Qt.BypassWindowManagerHint

    property string currentSectionId
    property var presetColors: [
                    {"label": dsTr("bleu de France"), "color": "#2e96ea"},
                    {"label": dsTr("Turquoise"), "color": "#38ecd9"},
                    {"label": dsTr("UFO green"), "color": "#37eb74"},
                    {"label": dsTr("Green yellow"), "color": "#a9eb3c"},
                    {"label": dsTr("Gorse"), "color": "#f9e741"},
                    {"label": dsTr("Energy yellow"), "color": "#ebd950"},
                    {"label": dsTr("Sun"), "color": "#fa8935"},
                    {"label": dsTr("Radical red"), "color": "#f34257"},
                    {"label": dsTr("Lavender indigo"), "color": "#b560f8"},
                    {"label": dsTr("Royal blue"), "color": "#2a65e9"},
                    {"label": dsTr("Aluminum"), "color": "#969696"},
                    {"label": dsTr("Clean white"), "color": "#ffffff"},
                ]

    signal scrollToPrivate (string sectionId)

    function scrollTo(sectionId) { scrollToPrivate(sectionId) }

    function scrollToSubtitle() { scrollTo("subtitle_settings") }

    content: DPreferenceView {
        id: preference_view
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        sectionListWidth:  100
        layer.enabled: true

        sections: [
            {
                "sectionId": "basic_playback",
                "sectionName": dsTr("Basic settings"),
                "subSections": [
                    {
                        "sectionId": "basic_playback",
                        "sectionName": dsTr("Playback"),
                        "subSections": []
                    },                    
                    {
                        "sectionId": "basic_time_span",
                        "sectionName": dsTr("Time span"),
                        "subSections": []
                    }
                ]
            },
            {
                "sectionId": "keyboard_playback",
                "sectionName": dsTr("Keyboard shortcuts"),
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
                        "sectionName": dsTr("Subtitles"),
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
                "sectionId": "subtitle_settings",
                "sectionName": dsTr("Subtitle settings"),
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

        function checkShortcutsDuplication(entryName, shortcut) {
            var keyboard_sections = [keyboard_playback, keyboard_frame_sound, keyboard_files, keyboard_subtitle]
            for (var i = 0; i < keyboard_sections.length; i++) {
                for (var j = 0; j < keyboard_sections[i].content.length; j++) {
                    var entry = keyboard_sections[i].content[j]
                    if (entry.title != entryName && entry.hotKey && entry.hotKey == shortcut) {
                        return [entry.title, keyboard_sections[i].title]
                    }
                }
            }

            return null
        }

        function disableShortcut(entryName, shortcut) {
            var keyboard_sections = [keyboard_playback, keyboard_frame_sound, keyboard_files, keyboard_subtitle]
            for (var i = 0; i < keyboard_sections.length; i++) {
                for (var j = 0; j < keyboard_sections[i].content.length; j++) {
                    var entry = keyboard_sections[i].content[j]
                    print(entry.title, entry.hotKey)
                    if (entry.title != entryName && entry.hotKey && entry.hotKey == shortcut) {
                        entry.disableShortcut()
                    }
                }
            }
        }

        Item {
            visible: false
            Timer {
                id: scroll_to_timer
                interval: 1000

                property string sectionId

                onTriggered: preference_view.scrollTo(sectionId)

                function schedule(sectionId) {
                    scroll_to_timer.sectionId = sectionId
                    scroll_to_timer.start()
                }
            }

            Connections {
                target: window
                onScrollToPrivate: scroll_to_timer.schedule(sectionId)
            }
        }

        SectionContent { title: dsTr("Basic settings"); sectionId: "basic_playback"; topSpaceHeight: 10 }

        SectionContent { 
            id: basic_playback
            title: dsTr("Playback")
            sectionId: "basic_playback"
            showSep: false
            topSpaceHeight: 10
            bottomSpaceHeight: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: dsTr("Enter fullscreen on opening file")
                checked: config.playerFullscreenOnOpenFile
                onClicked: config.playerFullscreenOnOpenFile = checked
            }

            DCheckBox {
                text: dsTr("Apply the size last time closed")
                checked: config.playerApplyLastClosedSize
                onClicked: config.playerApplyLastClosedSize = checked
            }

            DCheckBox {
                text: dsTr("Clear playlist on opening new file")
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
                text: dsTr("Show preview when hovering over progress bar")
                checked: config.playerShowPreview
                onClicked: config.playerShowPreview = checked
            }
            DCheckBox {
                text: dsTr("Allow multiple instance")
                checked: config.playerMultipleProgramsAllowed
                onClicked: config.playerMultipleProgramsAllowed = checked
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

        }
            
        SectionContent { 
            id: basic_time_step
            title: dsTr("Time span")
            sectionId: "basic_time_span"
            showSep: false
            topSpaceHeight: 10
            bottomSpaceHeight: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            SpinnerRow {
                title: dsTr("Forward/Rewind")
                min: 1.0
                max: 30.0
                text: config.playerForwardRewindStep

                onValueChanged: config.playerForwardRewindStep = value + 0.0
            }
        }

        SectionContent { title: dsTr("Keyboard shortcuts"); sectionId: ""; topSpaceHeight: 10 }

        SectionContent { 
            id: keyboard_playback
            title: dsTr("Playback")
            sectionId: "keyboard_playback"
            showSep: false
            topSpaceHeight: 10
            bottomSpaceHeight: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: dsTr("Enable keyboard shortcuts")
                checked: config.hotkeysPlayHotkeyEnabled
                onClicked: config.hotkeysPlayHotkeyEnabled = checked
            }
            HotKeyInputRow {
                title: dsTr("Pause/Play")
                hotKey: config.hotkeysPlayTogglePlay || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysPlayTogglePlay = ""
                    print(config.hotkeysPlayTogglePlay)
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysPlayTogglePlay = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysPlayTogglePlay = hotKey
                }

                onHotkeyCancelled: {
                    hotKey = Qt.binding(function() { return config.hotkeysPlayTogglePlay || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Forward")
                hotKey: config.hotkeysPlayForward || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysPlayForward = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysPlayForward = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysPlayForward = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysPlayForward
                    hotKey = Qt.binding(function() { return config.hotkeysPlayForward || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Rewind")
                hotKey: config.hotkeysPlayBackward || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysPlayBackward = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysPlayBackward = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysPlayBackward = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysPlayBackward
                    hotKey = Qt.binding(function() { return config.hotkeysPlayBackward || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Fullscreen")
                hotKey: config.hotkeysPlayToggleFullscreen || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysPlayToggleFullscreen = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysPlayToggleFullscreen = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysPlayToggleFullscreen = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysPlayToggleFullscreen
                    hotKey = Qt.binding(function() { return config.hotkeysPlayToggleFullscreen || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Playlist")
                hotKey: config.hotkeysPlayTogglePlaylist || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysPlayTogglePlaylist = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysPlayTogglePlaylist = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysPlayTogglePlaylist = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysPlayTogglePlaylist
                    hotKey = Qt.binding(function() { return config.hotkeysPlayTogglePlaylist || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Speed up")
                hotKey: config.hotkeysPlaySpeedUp || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysPlaySpeedUp = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysPlaySpeedUp = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysPlaySpeedUp = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysPlaySpeedUp
                    hotKey = Qt.binding(function() { return config.hotkeysPlaySpeedUp || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Slow down")
                hotKey: config.hotkeysPlaySlowDown || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysPlaySlowDown = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysPlaySlowDown = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysPlaySlowDown = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysPlaySlowDown
                    hotKey = Qt.binding(function() { return config.hotkeysPlaySlowDown || dsTr("Disabled") })
                }
            }
        }
        SectionContent { 
            id: keyboard_frame_sound
            title: dsTr("Frame/Sound")
            sectionId: "keyboard_frame_sound"
            showSep: false
            topSpaceHeight: 10
            bottomSpaceHeight: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: dsTr("Enable keyboard shortcuts")
                checked: config.hotkeysFrameSoundHotkeyEnabled
                onClicked: config.hotkeysFrameSoundHotkeyEnabled = checked
            }

            HotKeyInputRow {
                title: dsTr("Mini mode")
                hotKey: config.hotkeysFrameSoundToggleMiniMode || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysFrameSoundToggleMiniMode = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysFrameSoundToggleMiniMode = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysFrameSoundToggleMiniMode = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysFrameSoundToggleMiniMode
                    hotKey = Qt.binding(function() { return config.hotkeysFrameSoundToggleMiniMode || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Rotate counterclockwise")
                hotKey: config.hotkeysFrameSoundRotateAnticlockwise || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysFrameSoundRotateAnticlockwise = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysFrameSoundRotateAnticlockwise = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysFrameSoundRotateAnticlockwise = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysFrameSoundRotateAnticlockwise
                    hotKey = Qt.binding(function() { return config.hotkeysFrameSoundRotateAnticlockwise || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Rotate clockwise")
                hotKey: config.hotkeysFrameSoundRotateClockwise || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysFrameSoundRotateClockwise = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysFrameSoundRotateClockwise = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysFrameSoundRotateClockwise = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysFrameSoundRotateClockwise
                    hotKey = Qt.binding(function() { return config.hotkeysFrameSoundRotateClockwise || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Volume up")
                hotKey: config.hotkeysFrameSoundIncreaseVolume || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysFrameSoundIncreaseVolume = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysFrameSoundIncreaseVolume = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysFrameSoundIncreaseVolume = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysFrameSoundIncreaseVolume
                    hotKey = Qt.binding(function() { return config.hotkeysFrameSoundIncreaseVolume || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Volume down")
                hotKey: config.hotkeysFrameSoundDecreaseVolume || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysFrameSoundDecreaseVolume = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysFrameSoundDecreaseVolume = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysFrameSoundDecreaseVolume = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysFrameSoundDecreaseVolume
                    hotKey = Qt.binding(function() { return config.hotkeysFrameSoundDecreaseVolume || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Mute")
                hotKey: config.hotkeysFrameSoundToggleMute || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysFrameSoundToggleMute = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysFrameSoundToggleMute = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysFrameSoundToggleMute = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysFrameSoundToggleMute
                    hotKey = Qt.binding(function() { return config.hotkeysFrameSoundToggleMute || dsTr("Disabled") })
                }
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
                text: dsTr("Enable keyboard shortcuts")
                checked: config.hotkeysFilesHotkeyEnabled
                onClicked: config.hotkeysFilesHotkeyEnabled = checked                
            }

            HotKeyInputRow {
                title: dsTr("Open file")
                hotKey: config.hotkeysFilesOpenFile || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysFilesOpenFile = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysFilesOpenFile = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysFilesOpenFile = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysFilesOpenFile
                    hotKey = Qt.binding(function() { return config.hotkeysFilesOpenFile || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Open previous")
                hotKey: config.hotkeysFilesPlayPrevious || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysFilesPlayPrevious = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysFilesPlayPrevious = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysFilesPlayPrevious = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysFilesPlayPrevious
                    hotKey = Qt.binding(function() { return config.hotkeysFilesPlayPrevious || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Open next")
                hotKey: config.hotkeysFilesPlayNext || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysFilesPlayNext = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysFilesPlayNext = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysFilesPlayNext = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysFilesPlayNext
                    hotKey = Qt.binding(function() { return config.hotkeysFilesPlayNext || dsTr("Disabled") })
                }
            }
        }
        SectionContent { 
            id: keyboard_subtitle
            title: dsTr("Subtitles")
            sectionId: "keyboard_subtitle"
            showSep: false
            topSpaceHeight: 10
            bottomSpaceHeight: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            DCheckBox {
                text: dsTr("Enable keyboard shortcuts")
                checked: config.hotkeysSubtitlesHotkeyEnabled
                onClicked: config.hotkeysSubtitlesHotkeyEnabled = checked                
            }

            HotKeyInputRow {
                title: dsTr("Forward 0.5s")
                hotKey: config.hotkeysSubtitlesSubtitleForward || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysSubtitlesSubtitleForward = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysSubtitlesSubtitleForward = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysSubtitlesSubtitleForward = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysSubtitlesSubtitleForward
                    hotKey = Qt.binding(function() { return config.hotkeysSubtitlesSubtitleForward || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Delay 0.5s")
                hotKey: config.hotkeysSubtitlesSubtitleBackward || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysSubtitlesSubtitleBackward = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysSubtitlesSubtitleBackward = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysSubtitlesSubtitleBackward = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysSubtitlesSubtitleBackward
                    hotKey = Qt.binding(function() { return config.hotkeysSubtitlesSubtitleBackward || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Subtitle up")
                hotKey: config.hotkeysSubtitlesSubtitleMoveUp || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysSubtitlesSubtitleMoveUp = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysSubtitlesSubtitleMoveUp = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysSubtitlesSubtitleMoveUp = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysSubtitlesSubtitleMoveUp
                    hotKey = Qt.binding(function() { return config.hotkeysSubtitlesSubtitleMoveUp || dsTr("Disabled") })
                }
            }
            HotKeyInputRow {
                title: dsTr("Subtitle down")
                hotKey: config.hotkeysSubtitlesSubtitleMoveDown || dsTr("Disabled")

                function disableShortcut() {
                    config.hotkeysSubtitlesSubtitleMoveDown = ""
                }

                onHotkeySet: { 
                    var checkResult = preference_view.checkShortcutsDuplication(title, hotkey)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        config.hotkeysSubtitlesSubtitleMoveDown = hotkey 
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, hotKey)
                    config.hotkeysSubtitlesSubtitleMoveDown = hotKey
                }

                onHotkeyCancelled: {
                    text = config.hotkeysSubtitlesSubtitleMoveDown
                    hotKey = Qt.binding(function() { return config.hotkeysSubtitlesSubtitleMoveDown || dsTr("Disabled") })
                }
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
                title: dsTr("Left click")
                input.parentWindow: window
                input.selectIndex: config.othersLeftClick ? 0 : 1
                input.menu.labels: [dsTr("Pause/Play"), dsTr("Disabled")]

                onMenuSelect: config.othersLeftClick = index == 0
            }
            ComboBoxRow {
                title: dsTr("Double click")
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
            title: dsTr("Subtitle settings")
            sectionId: "subtitle_settings"
            topSpaceHeight: 10
            bottomSpaceHeight: 10

            DCheckBox {
                text: dsTr("Subtitles loaded automatically")
                checked: config.subtitleAutoLoad
                onClicked: config.subtitleAutoLoad = checked  
            }

            ComboBoxRow {
                title: dsTr("Font")
                input.parentWindow: window
                input.selectIndex: config.subtitleFontFamily ? Qt.fontFamilies().indexOf(config.subtitleFontFamily) 
                                                            : Qt.fontFamilies().indexOf(getSystemFontFamily())
                input.menu.labels: Qt.fontFamilies()

                onMenuSelect: config.subtitleFontFamily = Qt.fontFamilies()[index]
            }

            ColorComboBoxRow {
                title: dsTr("Font color")
                input.parentWindow: window
                input.selectIndex: {
                    for (var i = 0; i < presetColors.length; i++) {
                        if (presetColors[i].color == config.subtitleFontColor) {
                            return i
                        }
                    }
                    return -1
                }
                input.menu.items: window.presetColors

                onMenuSelect: config.subtitleFontColor = window.presetColors[index].color
            }

            SpinnerRow {
                title: dsTr("Size")
                min: 10
                max: 30
                text: config.subtitleFontSize

                onValueChanged: config.subtitleFontSize = value
            }

            SpinnerRow {
                title: dsTr("Border width")
                min: 0
                max: 6
                text: config.subtitleFontBorderSize

                onValueChanged: config.subtitleFontBorderSize = value + 0.0
            }

            ColorComboBoxRow {
                title: dsTr("Border color")
                input.parentWindow: window
                input.selectIndex: {
                    for (var i = 0; i < presetColors.length; i++) {
                        if (presetColors[i].color == config.subtitleFontBorderColor) {
                            return i
                        }
                    }
                    return -1
                }
                input.menu.items: window.presetColors

                onMenuSelect: config.subtitleFontBorderColor = window.presetColors[index].color
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

            SpinnerRow {
                title: dsTr("Subtitle Delay")
                min: -30
                max: 30
                text: player.subtitleDelay

                onValueChanged: player.subtitleDelay = value * 1000
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