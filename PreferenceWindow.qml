import QtQuick 2.1
import QtQuick.Controls 1.1
import Deepin.Widgets 1.0

DPreferenceWindow {
    id: window
    width: 560
    height: 480
    flags: Qt.BypassWindowManagerHint

    actionButtonText: dsTr("Reset")

    property string currentSectionId
    property var presetColors: [
                    {"label": dsTr("Black"), "color": "black"},
                    {"label": dsTr("bleu de France"), "color": "#2e96ea"},
                    {"label": dsTr("Turquoise"), "color": "#38ecd9"},
                    {"label": dsTr("UFO green"), "color": "#37eb74"},
                    {"label": dsTr("Green yellow"), "color": "#a9eb3c"},
                    {"label": dsTr("Energy yellow"), "color": "#ebd950"},
                    {"label": dsTr("Sun"), "color": "#fa8935"},
                    {"label": dsTr("Radical red"), "color": "#f34257"},
                    {"label": dsTr("Lavender indigo"), "color": "#b560f8"},
                    {"label": dsTr("Royal blue"), "color": "#2a65e9"},
                    {"label": dsTr("Aluminum"), "color": "#969696"},
                    {"label": dsTr("Clean white"), "color": "#ffffff"},
                ]

    signal scrollToPrivate (string sectionId)

    onAction: { resetHotkeys() }

    function resetHotkeys() { config.resetHotkeys() }

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
                "sectionId": "basic_settings",
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
                "sectionId": "keyboard_shortcuts",
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

        onCurrentSectionIdChanged: {
            window.showActionButton = currentSectionId.indexOf("keyboard") != -1
        }

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

        SectionContent { title: dsTr("Basic settings"); sectionId: "basic_settings"; topSpaceHeight: 10 }

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
                text: dsTr("Allow multiple instances")
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

        SectionContent { title: dsTr("Keyboard shortcuts"); sectionId: "keyboard_shortcuts"; topSpaceHeight: 10 }

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
                hotKey: config.hotkeysPlayTogglePlay+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysPlayTogglePlay"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysPlayTogglePlay) }
            }
            HotKeyInputRow {
                title: dsTr("Forward")
                hotKey: config.hotkeysPlayForward+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysPlayForward"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysPlayForward) }
            }
            HotKeyInputRow {
                title: dsTr("Rewind")
                hotKey: config.hotkeysPlayBackward+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysPlayBackward"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysPlayBackward) }
            }
            HotKeyInputRow {
                title: dsTr("Fullscreen")
                hotKey: config.hotkeysPlayToggleFullscreen+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysPlayToggleFullscreen"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysPlayToggleFullscreen) }
            }
            HotKeyInputRow {
                title: dsTr("Playlist")
                hotKey: config.hotkeysPlayTogglePlaylist+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysPlayTogglePlaylist"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysPlayTogglePlaylist) }
            }
            HotKeyInputRow {
                title: dsTr("Accelerate playback")
                hotKey: config.hotkeysPlaySpeedUp+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysPlaySpeedUp"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysPlaySpeedUp) }
            }
            HotKeyInputRow {
                title: dsTr("Decelerate playback")
                hotKey: config.hotkeysPlaySlowDown+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysPlaySlowDown"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysPlaySlowDown) }
            }
            HotKeyInputRow {
                title: dsTr("Restore playback speed")
                hotKey: config.hotkeysPlayRestoreSpeed+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysPlayRestoreSpeed"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysPlayRestoreSpeed) }
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
                hotKey: config.hotkeysFrameSoundToggleMiniMode+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysFrameSoundToggleMiniMode"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysFrameSoundToggleMiniMode) }
            }
            HotKeyInputRow {
                title: dsTr("Rotate counterclockwise")
                hotKey: config.hotkeysFrameSoundRotateAnticlockwise+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysFrameSoundRotateAnticlockwise"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysFrameSoundRotateAnticlockwise) }
            }
            HotKeyInputRow {
                title: dsTr("Rotate clockwise")
                hotKey: config.hotkeysFrameSoundRotateClockwise+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysFrameSoundRotateClockwise"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysFrameSoundRotateClockwise) }
            }
            HotKeyInputRow {
                title: dsTr("Volume up")
                hotKey: config.hotkeysFrameSoundIncreaseVolume+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysFrameSoundIncreaseVolume"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysFrameSoundIncreaseVolume) }
            }
            HotKeyInputRow {
                title: dsTr("Volume down")
                hotKey: config.hotkeysFrameSoundDecreaseVolume+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysFrameSoundDecreaseVolume"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysFrameSoundDecreaseVolume) }
            }
            HotKeyInputRow {
                title: dsTr("Mute")
                hotKey: config.hotkeysFrameSoundToggleMute+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysFrameSoundToggleMute"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysFrameSoundToggleMute) }
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
                title: dsTr("Open a file")
                hotKey: config.hotkeysFilesOpenFile+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysFilesOpenFile"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysFilesOpenFile) }
            }
            HotKeyInputRow {
                title: dsTr("Open previous")
                hotKey: config.hotkeysFilesPlayPrevious+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysFilesPlayPrevious"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysFilesPlayPrevious) }
            }
            HotKeyInputRow {
                title: dsTr("Open next")
                hotKey: config.hotkeysFilesPlayNext+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysFilesPlayNext"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysFilesPlayNext) }
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
                hotKey: config.hotkeysSubtitlesSubtitleForward+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysSubtitlesSubtitleForward"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysSubtitlesSubtitleForward) }
            }
            HotKeyInputRow {
                title: dsTr("Delay 0.5s")
                hotKey: config.hotkeysSubtitlesSubtitleBackward+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysSubtitlesSubtitleBackward"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysSubtitlesSubtitleBackward) }
            }
            HotKeyInputRow {
                title: dsTr("Subtitle up")
                hotKey: config.hotkeysSubtitlesSubtitleMoveUp+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysSubtitlesSubtitleMoveUp"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysSubtitlesSubtitleMoveUp) }
            }
            HotKeyInputRow {
                title: dsTr("Subtitle down")
                hotKey: config.hotkeysSubtitlesSubtitleMoveDown+"" || dsTr("Disabled")
                actualSettingEntry: "hotkeysSubtitlesSubtitleMoveDown"

                onHotkeySet: {
                    var checkResult = preference_view.checkShortcutsDuplication(title, text)
                    if (checkResult != null) {
                        warning(checkResult[0], checkResult[1])
                    } else {
                        setShortcut(text)
                    }
                }

                onHotkeyReplaced: {
                    preference_view.disableShortcut(title, text)
                    setShortcut(text)
                }

                onHotkeyCancelled: { setShortcut(config.hotkeysSubtitlesSubtitleMoveDown) }
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

            // TODO:
            // keep this exactly the same as the font combobox in dde-control-center
            // ComboBoxRow {
            //     title: dsTr("Font")
            //     input.parentWindow: window
            //     input.selectIndex: config.subtitleFontFamily ? Qt.fontFamilies().indexOf(config.subtitleFontFamily)
            //                                                 : Qt.fontFamilies().indexOf(getSystemFontFamily())
            //     input.menu.labels: Qt.fontFamilies()

            //     onMenuSelect: config.subtitleFontFamily = Qt.fontFamilies()[index]
            // }

            // TODO:
            // this line shouldn't be there, just a strange work around here,
            // waiting for Wanqing to fix this problem ;)
            ColorComboBoxRow { visible: false; input.parentWindow: window }

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
        AboutSection { version: Qt.application.version }
    }
}